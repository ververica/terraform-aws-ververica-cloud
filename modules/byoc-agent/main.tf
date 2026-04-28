data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

check "oidc_inputs" {
  assert {
    condition     = (var.oidc_provider_url != null) != (var.existing_oidc_provider_arn != null)
    error_message = "Exactly one of oidc_provider_url or existing_oidc_provider_arn must be set."
  }
}

# ---------------------------------------------------------------------------
# OIDC provider (created or referenced)
# ---------------------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "this" {
  count = local.create_oidc_provider ? 1 : 0

  url            = trimsuffix(var.oidc_provider_url, "/")
  client_id_list = var.oidc_client_id_list

  tags = var.tags
}

data "aws_iam_openid_connect_provider" "existing" {
  count = local.create_oidc_provider ? 0 : 1
  arn   = var.existing_oidc_provider_arn
}

# ---------------------------------------------------------------------------
# S3 bucket
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.bucket_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    expose_headers  = var.cors_exposed_headers
    max_age_seconds = var.cors_max_age_seconds
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.bucket_block_public_access ? 1 : 0

  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.bucket_versioning_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.bucket_encryption_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.bucket_kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.bucket_kms_key_arn
    }
    bucket_key_enabled = var.bucket_kms_key_arn != null
  }
}

data "aws_iam_policy_document" "bucket_tls_only" {
  count = var.bucket_enforce_tls ? 1 : 0

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = var.bucket_enforce_tls ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket_tls_only[0].json

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# ---------------------------------------------------------------------------
# Tenant role (S3 access for the agent)
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "tenant_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.admin.arn]
    }
  }
}

resource "aws_iam_role" "tenant" {
  name               = var.tenant_role_name
  assume_role_policy = data.aws_iam_policy_document.tenant_assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "tenant" {
  statement {
    sid    = "AgentBucketAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "tenant" {
  name        = local.tenant_policy_name
  description = "Permissions used by the Ververica Agent's tenant role."
  policy      = data.aws_iam_policy_document.tenant.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "tenant" {
  role       = aws_iam_role.tenant.name
  policy_arn = aws_iam_policy.tenant.arn
}

resource "aws_iam_role_policy_attachment" "tenant_extra" {
  for_each = toset(var.additional_tenant_role_policy_arns)

  role       = aws_iam_role.tenant.name
  policy_arn = each.value
}

# ---------------------------------------------------------------------------
# Admin role (assumed via OIDC web identity, can assume the tenant role)
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "admin_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.resolved_oidc_provider_arn]
    }

    dynamic "condition" {
      for_each = length(var.admin_role_subject_claims) > 0 ? [1] : []
      content {
        test     = "StringLike"
        variable = "${local.oidc_issuer_hostpath}:sub"
        values   = var.admin_role_subject_claims
      }
    }

    dynamic "condition" {
      for_each = length(var.admin_role_audience_claims) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "${local.oidc_issuer_hostpath}:aud"
        values   = var.admin_role_audience_claims
      }
    }
  }
}

resource "aws_iam_role" "admin" {
  name               = var.admin_role_name
  assume_role_policy = data.aws_iam_policy_document.admin_assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "admin" {
  statement {
    sid       = "AssumeTenantRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.tenant.arn]
  }
}

resource "aws_iam_policy" "admin" {
  name        = local.admin_policy_name
  description = "Permissions used by the Ververica Agent's admin role."
  policy      = data.aws_iam_policy_document.admin.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.admin.name
  policy_arn = aws_iam_policy.admin.arn
}

resource "aws_iam_role_policy_attachment" "admin_extra" {
  for_each = toset(var.additional_admin_role_policy_arns)

  role       = aws_iam_role.admin.name
  policy_arn = each.value
}

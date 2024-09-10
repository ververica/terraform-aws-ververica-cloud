locals {
  enable_private_connection = var.enable_elasticache || var.enable_msk || var.enable_private_connection
}

###########################################################
## Private Connection IAM Role with Policies             ##
###########################################################
data "aws_iam_policy_document" "trust_policy" {
  statement {
    sid     = "VervericaCloudAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.ververica_cloud_aws_account}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.ververica_cloud_workspace_id]
    }
  }
}

resource "aws_iam_role" "ververica_cloud_iam_role" {
  name                  = var.role_name
  name_prefix           = var.role_name_prefix
  path                  = var.role_path
  description           = var.role_description
  force_detach_policies = var.force_detach_policies
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.role_permissions_boundary_arn
  assume_role_policy    = data.aws_iam_policy_document.trust_policy.json

}

data "aws_iam_policy_document" "kinesis" {
  count = var.enable_kinesis ? 1 : 0
  statement {
    sid       = "KinesisPolicy"
    effect    = "Allow"
    actions   = ["kinesis:*"]
    resources = var.kinesis_stream_arns == null ? ["*"] : var.kinesis_stream_arns
  }
}

resource "aws_iam_role_policy" "kinesis" {
  count  = var.enable_kinesis ? 1 : 0
  name   = "VervericaCloud-Kinesis-InlinePolicy"
  role   = aws_iam_role.ververica_cloud_iam_role.id
  policy = data.aws_iam_policy_document.kinesis[0].json
}

data "aws_iam_policy_document" "dynamodb" {
  count = var.enable_dynamodb ? 1 : 0
  statement {
    sid       = "DynamoDBPolicy"
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = var.dynamodb_table_arns == null ? ["*"] : var.dynamodb_table_arns
  }
}

resource "aws_iam_role_policy" "dynamodb" {
  count  = var.enable_dynamodb ? 1 : 0
  name   = "VervericaCloud-DynamoDB-InlinePolicy"
  role   = aws_iam_role.ververica_cloud_iam_role.id
  policy = data.aws_iam_policy_document.dynamodb[0].json
}

data "aws_iam_policy_document" "s3" {
  count = var.enable_s3 ? 1 : 0
  statement {
    sid       = "S3BucketListPolicy"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = var.s3_bucket_arns == null ? ["*"] : var.s3_bucket_arns
  }
  statement {
    sid    = "S3BucketRWPolicy"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = var.s3_bucket_arns == null ? ["*"] : [for bucket in var.s3_bucket_arns : "${bucket}/*"]
  }
}

resource "aws_iam_role_policy" "s3" {
  count  = var.enable_s3 ? 1 : 0
  name   = "VervericaCloud-S3-InlinePolicy"
  role   = aws_iam_role.ververica_cloud_iam_role.id
  policy = data.aws_iam_policy_document.s3[0].json
}

data "aws_iam_policy_document" "elasticache" {
  count = var.enable_elasticache ? 1 : 0
  statement {
    sid    = "ElasticachePolicy"
    effect = "Allow"
    actions = [
      "elasticache:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "elasticache" {
  count  = var.enable_elasticache ? 1 : 0
  name   = "VervericaCloud-Elasticache-InlinePolicy"
  role   = aws_iam_role.ververica_cloud_iam_role.id
  policy = data.aws_iam_policy_document.elasticache[0].json
}

data "aws_iam_policy_document" "msk" {
  count = var.enable_msk ? 1 : 0
  statement {
    sid    = "MSKPolicy"
    effect = "Allow"
    actions = [
      "kafka-cluster:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "msk" {
  count  = var.enable_msk ? 1 : 0
  name   = "VervericaCloud-MSK-InlinePolicy"
  role   = aws_iam_role.ververica_cloud_iam_role.id
  policy = data.aws_iam_policy_document.msk[0].json
}

data "aws_iam_policy_document" "private_connection" {
  count = local.enable_private_connection ? 1 : 0
  statement {
    sid    = "AcceptVpcEndpointConnectionPolicy"
    effect = "Allow"
    actions = [
      "ec2:AcceptVpcEndpointConnections",
      "ec2:DescribeVpcEndpointServices"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "private_connection" {
  count  = local.enable_private_connection ? 1 : 0
  name   = "VervericaCloud-PrivateConnection-InlinePolicy"
  role   = aws_iam_role.ververica_cloud_iam_role.id
  policy = data.aws_iam_policy_document.private_connection[0].json
}

data "aws_iam_policy_document" "aws_clive_write_data" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.published_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:DeleteObject*",
      "s3:Put*",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/pdm-dataset/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/metrics/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/common-model-inputs/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/analytical-dataset/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/aws-clive/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.published_bucket_cmk.arn}",
    ]
  }
}

resource "aws_iam_policy" "aws_clive_write_data" {
  name        = "AwsCliveWriteData"
  description = "Allow writing of aws-clive files and metrics"
  policy      = data.aws_iam_policy_document.aws_clive_write_data.json
}


data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aws_clive" {
  name               = "aws_clive"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.tags
}

resource "aws_iam_instance_profile" "aws_clive" {
  name = "aws_clive"
  role = aws_iam_role.aws_clive.id
}

resource "aws_iam_role_policy_attachment" "ec2_for_ssm_attachment" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "aws_clive_ebs_cmk" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_ebs_cmk_encrypt.arn
}

resource "aws_iam_role_policy_attachment" "aws_clive_acm" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_acm.arn
}

data "aws_iam_policy_document" "aws_clive_extra_ssm_properties" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstanceStatus",
    ]

    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ds:CreateComputer",
      "ds:DescribeDirectories",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::eu-west-2.elasticmapreduce",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::eu-west-2.elasticmapreduce/libs/script-runner/*",
    ]
  }
}

resource "aws_iam_policy" "aws_clive_extra_ssm_properties" {
  name        = "AwsCliveExtraSSM"
  description = "Additional properties to allow for SSM and writing logs"
  policy      = data.aws_iam_policy_document.aws_clive_extra_ssm_properties.json
}

resource "aws_iam_role_policy_attachment" "aws_clive_extra_ssm_properties" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_extra_ssm_properties.arn
}

resource "aws_iam_role_policy_attachment" "aws_clive_certificates" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_certificates.arn
}

data "aws_iam_policy_document" "aws_clive_write_logs" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.security-tools.outputs.logstore_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
      "s3:PutObject*",

    ]

    resources = [
      "${data.terraform_remote_state.security-tools.outputs.logstore_bucket.arn}/${local.s3_log_prefix}",
    ]
  }
}

resource "aws_iam_policy" "aws_clive_write_logs" {
  name        = "aws-clive-WriteLogs"
  description = "Allow writing of aws_clive logs"
  policy      = data.aws_iam_policy_document.aws_clive_write_logs.json
}

resource "aws_iam_role_policy_attachment" "aws_clive_write_logs" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_write_logs.arn
}

data "aws_iam_policy_document" "aws_clive_read_config" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.config_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.config_bucket_cmk.arn}",
    ]
  }
}

resource "aws_iam_policy" "aws_clive_read_config" {
  name        = "aws-clive-ReadConfig"
  description = "Allow reading of aws_clive config files"
  policy      = data.aws_iam_policy_document.aws_clive_read_config.json
}

resource "aws_iam_role_policy_attachment" "aws_clive_read_config" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_read_config.arn
}

data "aws_iam_policy_document" "aws_clive_read_artefacts" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.management_artefact.outputs.artefact_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "${data.terraform_remote_state.management_artefact.outputs.artefact_bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      data.terraform_remote_state.management_artefact.outputs.artefact_bucket.cmk_arn,
    ]
  }
}

resource "aws_iam_policy" "aws_clive_read_artefacts" {
  name        = "aws-clive-ReadArtefacts"
  description = "Allow reading of aws_clive software artefacts"
  policy      = data.aws_iam_policy_document.aws_clive_read_artefacts.json
}

resource "aws_iam_role_policy_attachment" "aws_clive_read_artefacts" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_read_artefacts.arn
}

data "aws_iam_policy_document" "aws_clive_write_dynamodb" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "arn:aws:dynamodb:${var.region}:${local.account[local.environment]}:table/${local.data_pipeline_metadata}"
    ]
  }
}

resource "aws_iam_policy" "aws_clive_write_dynamodb" {
  name        = "AwsCliveDynamoDB"
  description = "Allows read and write access to ADG's EMRFS DynamoDB table"
  policy      = data.aws_iam_policy_document.aws_clive_write_dynamodb.json
}

resource "aws_iam_role_policy_attachment" "analytical_dataset_generator_dynamodb" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_write_dynamodb.arn
}

data "aws_iam_policy_document" "aws_clive_metadata_change" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:ModifyInstanceMetadataOptions",
      "ec2:*Tags",
    ]

    resources = [
      "arn:aws:ec2:${var.region}:${local.account[local.environment]}:instance/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "aws_clive_read_write_processed_bucket" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_read_write_processed_bucket.arn
}

resource "aws_iam_policy" "aws_clive_metadata_change" {
  name        = "aws-clive-MetadataOptions"
  description = "Allow editing of Metadata Options"
  policy      = data.aws_iam_policy_document.aws_clive_metadata_change.json
}

resource "aws_iam_role_policy_attachment" "aws_clive_metadata_change" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_metadata_change.arn
}

resource "aws_iam_role_policy_attachment" "aws_clive_write_data" {
  role       = aws_iam_role.aws_clive.name
  policy_arn = aws_iam_policy.aws_clive_write_data.arn
}

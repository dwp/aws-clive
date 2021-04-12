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

resource "aws_iam_role" "aws_emr_template_repository" {
  name               = "aws_emr_template_repository"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.tags
}

resource "aws_iam_instance_profile" "aws_emr_template_repository" {
  name = "aws_emr_template_repository"
  role = aws_iam_role.aws_emr_template_repository.id
}

resource "aws_iam_role_policy_attachment" "ec2_for_ssm_attachment" {
  role       = aws_iam_role.aws_emr_template_repository.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  role       = aws_iam_role.aws_emr_template_repository.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "aws_emr_template_repository_ebs_cmk" {
  role       = aws_iam_role.aws_emr_template_repository.name
  policy_arn = aws_iam_policy.aws_emr_template_repository_ebs_cmk_encrypt.arn
}

resource "aws_iam_role_policy_attachment" "aws_emr_template_repository_acm" {
  role       = aws_iam_role.aws_emr_template_repository.name
  policy_arn = aws_iam_policy.aws_emr_template_repository_acm.arn
}


data "aws_iam_policy_document" "aws_emr_template_repository_write_logs" {
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

resource "aws_iam_policy" "aws_emr_template_repository_write_logs" {
  name        = "AwsEmrTemplateRepositoryWriteLogs"
  description = "Allow writing of aws_emr_template_repository logs"
  policy      = data.aws_iam_policy_document.aws_emr_template_repository_write_logs.json
}

resource "aws_iam_role_policy_attachment" "aws_emr_template_repository_write_logs" {
  role       = aws_iam_role.aws_emr_template_repository.name
  policy_arn = aws_iam_policy.aws_emr_template_repository_write_logs.arn
}

data "aws_iam_policy_document" "aws_emr_template_repository_read_config" {
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

resource "aws_iam_policy" "aws_emr_template_repository_read_config" {
  name        = "AwsEmrTemplateRepositoryReadConfig"
  description = "Allow reading of aws_emr_template_repository config files"
  policy      = data.aws_iam_policy_document.aws_emr_template_repository_read_config.json
}

resource "aws_iam_role_policy_attachment" "aws_emr_template_repository_read_config" {
  role       = aws_iam_role.aws_emr_template_repository.name
  policy_arn = aws_iam_policy.aws_emr_template_repository_read_config.arn
}

data "aws_iam_policy_document" "aws_emr_template_repository_read_artefacts" {
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

resource "aws_iam_policy" "aws_emr_template_repository_read_artefacts" {
  name        = "AwsEmrTemplateRepositoryReadArtefacts"
  description = "Allow reading of aws_emr_template_repository software artefacts"
  policy      = data.aws_iam_policy_document.aws_emr_template_repository_read_artefacts.json
}

resource "aws_iam_role_policy_attachment" "aws_emr_template_repository_read_artefacts" {
  role       = aws_iam_role.aws_emr_template_repository.name
  policy_arn = aws_iam_policy.aws_emr_template_repository_read_artefacts.arn
}

data "aws_iam_policy_document" "aws_emr_template_repository_write_dynamodb" {
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

data "aws_iam_policy_document" "aws_emr_template_repository_metadata_change" {
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

resource "aws_iam_policy" "aws_emr_template_repository_metadata_change" {
  name        = "AwsEmrTemplateRepositoryMetadataOptions"
  description = "Allow editing of Metadata Options"
  policy      = data.aws_iam_policy_document.aws_emr_template_repository_metadata_change.json
}

resource "aws_iam_role_policy_attachment" "aws_emr_template_repository_metadata_change" {
  role       = aws_iam_role.aws_emr_template_repository.name
  policy_arn = aws_iam_policy.aws_emr_template_repository_metadata_change.arn
}

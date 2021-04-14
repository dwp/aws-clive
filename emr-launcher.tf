variable "emr_launcher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

resource "aws_lambda_function" "aws_clive_emr_launcher" {
  filename      = "${var.emr_launcher_zip["base_path"]}/emr-launcher-${var.emr_launcher_zip["version"]}.zip"
  function_name = "aws_clive_emr_launcher"
  role          = aws_iam_role.aws_clive_emr_launcher_lambda_role.arn
  handler       = "emr_launcher.handler.handler"
  runtime       = "python3.7"
  source_code_hash = filebase64sha256(
    format(
      "%s/emr-launcher-%s.zip",
      var.emr_launcher_zip["base_path"],
      var.emr_launcher_zip["version"]
    )
  )
  publish = false
  timeout = 60

  environment {
    variables = {
      EMR_LAUNCHER_CONFIG_S3_BUCKET = data.terraform_remote_state.common.outputs.config_bucket.id
      EMR_LAUNCHER_CONFIG_S3_FOLDER = "emr/aws_clive"
      EMR_LAUNCHER_LOG_LEVEL        = "debug"
    }
  }
}

resource "aws_iam_role" "aws_clive_emr_launcher_lambda_role" {
  name               = "aws_clive_emr_launcher_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.aws_clive_emr_launcher_assume_policy.json
}

data "aws_iam_policy_document" "aws_clive_emr_launcher_assume_policy" {
  statement {
    sid     = "AwsCliveEMRLauncherLambdaAssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "aws_clive_emr_launcher_read_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      format("arn:aws:s3:::%s/emr/aws_clive/*", data.terraform_remote_state.common.outputs.config_bucket.id)
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
    ]
  }
}

data "aws_iam_policy_document" "aws_clive_emr_launcher_runjobflow_policy" {
  statement {
    effect = "Allow"
    actions = [
      "elasticmapreduce:RunJobFlow",
      "elasticmapreduce:AddTags",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "aws_clive_emr_launcher_pass_role_document" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/*"
    ]
  }
}

resource "aws_iam_policy" "aws_clive_emr_launcher_read_s3_policy" {
  name        = "aws_cliveReadS3"
  description = "Allow aws_clive to read from S3 bucket"
  policy      = data.aws_iam_policy_document.aws_clive_emr_launcher_read_s3_policy.json
}

resource "aws_iam_policy" "aws_clive_emr_launcher_runjobflow_policy" {
  name        = "aws_cliveRunJobFlow"
  description = "Allow aws_clive to run job flow"
  policy      = data.aws_iam_policy_document.aws_clive_emr_launcher_runjobflow_policy.json
}

resource "aws_iam_policy" "aws_clive_emr_launcher_pass_role_policy" {
  name        = "aws_clivePassRole"
  description = "Allow aws_clive to pass role"
  policy      = data.aws_iam_policy_document.aws_clive_emr_launcher_pass_role_document.json
}

resource "aws_iam_role_policy_attachment" "aws_clive_emr_launcher_read_s3_attachment" {
  role       = aws_iam_role.aws_clive_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.aws_clive_emr_launcher_read_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_clive_emr_launcher_runjobflow_attachment" {
  role       = aws_iam_role.aws_clive_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.aws_clive_emr_launcher_runjobflow_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_clive_emr_launcher_pass_role_attachment" {
  role       = aws_iam_role.aws_clive_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.aws_clive_emr_launcher_pass_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_clive_emr_launcher_policy_execution" {
  role       = aws_iam_role.aws_clive_emr_launcher_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


resource "aws_acm_certificate" "aws_clive" {
  certificate_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  domain_name               = "aws-clive.${local.env_prefix[local.environment]}${local.dataworks_domain_name}"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}

data "aws_iam_policy_document" "aws_clive_acm" {
  statement {
    effect = "Allow"

    actions = [
      "acm:ExportCertificate",
    ]

    resources = [
      aws_acm_certificate.aws_clive.arn
    ]
  }
}

resource "aws_iam_policy" "aws_clive_acm" {
  name        = "ACMExport-aws-clive-Cert"
  description = "Allow export of aws-clive certificate"
  policy      = data.aws_iam_policy_document.aws_clive_acm.json
}


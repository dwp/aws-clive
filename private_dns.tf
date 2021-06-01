data "aws_secretsmanager_secret_version" "terraform_secrets" {
  provider  = aws.management_dns
  secret_id = "/concourse/dataworks/terraform"
}

resource "aws_service_discovery_service" "clive_services" {
  name = "clive-pushgateway"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.clive_services.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  tags = {
    Name = "clive_services"
  }
}

resource "aws_service_discovery_private_dns_namespace" "clive_services" {
  name = "${local.environment}.clive.services.${jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary)["dataworks_domain_name"]}"
  vpc  = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  tags = {
    Name = "clive_services"
  }
}

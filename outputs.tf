output "aws_clive_common_sg" {
  value = aws_security_group.aws_clive_common
}

output "aws_clive_emr_launcher_lambda" {
  value = aws_lambda_function.aws_clive_emr_launcher
}

output "private_dns" {
  value = {
    clive_service_discovery_dns = aws_service_discovery_private_dns_namespace.clive_services
    clive_service_discovery     = aws_service_discovery_service.clive_services
  }
}

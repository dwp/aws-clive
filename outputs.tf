output "aws_clive_common_sg" {
  value = aws_security_group.aws_clive_common
}

output "aws_clive_emr_launcher_lambda" {
  value = aws_lambda_function.aws_clive_emr_launcher
}

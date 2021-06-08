resource "aws_sns_topic" "clive_cw_trigger_sns" {
  name = "clive_cw_trigger_sns"

  tags = merge(
    local.common_tags,
    {
      "Name" = "clive_cw_trigger_sns"
    },
  )
}

output "clive_cw_trigger_sns_topic" {
  value = aws_sns_topic.clive_cw_trigger_sns
}

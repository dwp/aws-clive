resource "aws_cloudwatch_event_rule" "clive_failed" {
  name          = "clive_failed"
  description   = "Sends failed message to slack when clive cluster terminates with errors"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED_WITH_ERRORS"
    ],
    "name": [
      "aws-clive"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "clive_terminated" {
  name          = "clive_terminated"
  description   = "Sends terminated message to slack when clive cluster terminates by user request"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "aws-clive"
    ],
    "stateChangeReason": [
      "{\"code\":\"USER_REQUEST\",\"message\":\"User request\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "clive_success" {
  name          = "clive_success"
  description   = "checks that all steps complete"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "aws-clive"
    ],
    "stateChangeReason": [
      "{\"code\":\"ALL_STEPS_COMPLETED\",\"message\":\"Steps completed\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "clive_running" {
  name          = "clive_running"
  description   = "checks that clive has started running"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "RUNNING"
    ],
    "name": [
      "aws-clive"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "clive_failed" {
  count                     = local.clive_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "clive_failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster termination with errors"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.clive_failed.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "clive_failed",
      notification_type = "Error",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "clive_terminated" {
  count                     = local.clive_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "clive_terminated"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster terminated by user request"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.clive_terminated.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "clive_terminated",
      notification_type = "Information",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "clive_success" {
  count                     = local.clive_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "clive_success"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring clive completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.clive_success.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "clive_success",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "clive_running" {
  count                     = local.clive_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "clive_running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring clive completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.clive_running.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "clive_running",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}

# AWS IAM for Cloudwatch event triggers
data "aws_iam_policy_document" "cloudwatch_events_assume_role" {
  statement {
    sid    = "CloudwatchEventsAssumeRolePolicy"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}


resource "aws_cloudwatch_event_target" "clive_success_start_object_tagger" {
  target_id = "clive_success"
  rule      = aws_cloudwatch_event_rule.clive_success.name
  arn       = data.terraform_remote_state.aws_s3_object_tagger.outputs.s3_object_tagger_batch.clive_job_queue.arn
  role_arn  = aws_iam_role.allow_batch_job_submission.arn

  batch_target {
    job_definition = data.terraform_remote_state.aws_s3_object_tagger.outputs.s3_object_tagger_batch.job_definition.id
    job_name       = "pdm-success-cloudwatch-event"
  }

  input = "{\"Parameters\": {\"data-s3-prefix\": \"${local.data_classification.data_s3_prefix}\", \"csv-location\": \"s3://${local.data_classification.config_bucket.id}/${local.data_classification.config_prefix}/data_classification.csv\"}}"
}

resource "aws_iam_role" "allow_batch_job_submission" {
  name               = "CliveAllowBatchJobSubmission"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_events_assume_role.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "allow_batch_job_submission" {
  statement {
    sid    = "AllowBatchJobSubmission"
    effect = "Allow"

    actions = [
      "batch:SubmitJob",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "allow_batch_job_submission" {
  name   = "CliveAllowBatchJobSubmission"
  policy = data.aws_iam_policy_document.allow_batch_job_submission.json
}

resource "aws_iam_role_policy_attachment" "allow_batch_job_submission" {
  role       = aws_iam_role.allow_batch_job_submission.name
  policy_arn = aws_iam_policy.allow_batch_job_submission.arn
}

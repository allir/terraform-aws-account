variable "monitor" {
  description = <<EOF
Monitor AWS Account logins.

Add email addresses that should be notified.
EOF
  type = object({
    root_login = bool
    iam_login  = bool
    email_addresses = set(string)
  })
  default = {
    root_login = false
    iam_login  = false
    email_addresses = []
  }
}

resource "aws_sns_topic" "root_login" {
  provider = aws.us-east-1
  name = "root_login"

  tags = local.common_tags
}

resource "aws_sns_topic" "iam_login" {
  provider = aws.us-east-1
  name = "iam_login"

  tags = local.common_tags
}

resource "aws_sns_topic_policy" "root_login" {
  provider = aws.us-east-1
  arn = aws_sns_topic.root_login.arn
  policy = data.aws_iam_policy_document.sns_root_login.json
}

resource "aws_sns_topic_policy" "iam_login" {
  provider = aws.us-east-1
  arn = aws_sns_topic.iam_login.arn
  policy = data.aws_iam_policy_document.sns_iam_login.json
}

data "aws_iam_policy_document" "sns_root_login" {
  policy_id = "sns_root_login_topic"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.root_login.arn,
    ]

    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "SNS:Publish"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.root_login.arn,
    ]

    sid = "allow_events_to_publish"
  }
}

data "aws_iam_policy_document" "sns_iam_login" {
  policy_id = "sns_iam_login_topic"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.iam_login.arn,
    ]

    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "SNS:Publish"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.iam_login.arn,
    ]

    sid = "allow_events_to_publish"
  }
}

resource "aws_cloudwatch_event_rule" "root_login" {
  provider      = aws.us-east-1
  name          = "root-login"
  description   = "Successful login with root account"
  event_pattern = <<PATTERN
  {
    "detail-type": [
      "AWS Console Sign In via CloudTrail"
    ],
    "detail": {
      "userIdentity": {
        "type": [
          "Root"
        ]
      }
    }
  }
  PATTERN

  tags = local.common_tags
}

resource "aws_cloudwatch_event_rule" "iam_login" {
  provider      = aws.us-east-1
  name          = "iam-login"
  description   = "Successful IAM login"
  event_pattern = <<PATTERN
  {
    "detail-type": [
      "AWS Console Sign In via CloudTrail"
    ],
    "detail": {
      "userIdentity": {
        "type": [
          "IAMUser"
        ]
      }
    }
  }
  PATTERN

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "root_login" {
  provider  = aws.us-east-1
  count     = var.monitor.root_login ? 1 : 0
  rule      = aws_cloudwatch_event_rule.root_login.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.root_login.arn
}

resource "aws_cloudwatch_event_target" "iam_login" {
  provider  = aws.us-east-1
  count     = var.monitor.iam_login ? 1 : 0
  rule      = aws_cloudwatch_event_rule.iam_login.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.iam_login.arn
}

resource "aws_sns_topic_subscription" "root_login" {
  provider  = aws.us-east-1
  for_each  = var.monitor.email_addresses
  topic_arn = aws_sns_topic.root_login.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_sns_topic_subscription" "iam_login" {
  provider  = aws.us-east-1
  for_each  = var.monitor.email_addresses
  topic_arn = aws_sns_topic.iam_login.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "root_login" {
  provider            = aws.us-east-1
  alarm_name          = "root-login"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "TriggeredRules"
  namespace           = "AWS/Events"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "IAM Root Login CloudWatch Rule has been triggered"
  alarm_actions       = [aws_sns_topic.root_login.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.root_login.name
  }
  
  tags = local.common_tags
}

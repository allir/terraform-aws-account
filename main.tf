provider "aws" {
  region = var.aws_region
}

resource "aws_iam_account_alias" "account_alias" {
  account_alias = var.account_name
}

resource "aws_iam_account_password_policy" "default" {
  allow_users_to_change_password = true
  minimum_password_length        = 12
  password_reuse_prevention      = 0

  max_password_age               = 0
  hard_expiry                    = false

  require_lowercase_characters   = false
  require_numbers                = false
  require_symbols                = false
  require_uppercase_characters   = false
}

resource "aws_iam_group" "admin" {
  name = "admin"
}

resource "aws_iam_group_policy_attachment" "admin_policy_attacment" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group" "billing" {
  name = "billing"
}

resource "aws_iam_group_policy_attachment" "billing_policy_attacment" {
  group      = aws_iam_group.billing.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_policy" "mfa_policy" {
  name = "RequireMFA"
  policy = file("./templates/require-mfa-policy.json")
}

resource "aws_iam_group" "mfa" {
  name = "mfa"
}

resource "aws_iam_group_policy_attachment" "mfa_policy_attacment" {
  group      = aws_iam_group.mfa.name
  policy_arn = aws_iam_policy.mfa_policy.arn
}

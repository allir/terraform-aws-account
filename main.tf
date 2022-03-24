terraform {
  required_providers {
    aws = {
      version = "~> 3.75"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws.region
  allowed_account_ids = var.aws.allowed_account_ids
}

data "aws_caller_identity" "current" {}

resource "aws_iam_account_alias" "this" {
  account_alias = var.account_name
}

resource "aws_iam_account_password_policy" "this" {
  allow_users_to_change_password = var.password_policy.allow_users_to_change_password
  minimum_password_length        = var.password_policy.minimum_password_length
  password_reuse_prevention      = var.password_policy.password_reuse_prevention

  max_password_age               = var.password_policy.max_password_age
  hard_expiry                    = var.password_policy.hard_expiry

  require_lowercase_characters   = var.password_policy.require_lowercase_characters
  require_uppercase_characters   = var.password_policy.require_uppercase_characters
  require_numbers                = var.password_policy.require_numbers
  require_symbols                = var.password_policy.require_symbols
}

resource "aws_iam_group" "admin" {
  name = "admin"
}

resource "aws_iam_group_policy_attachment" "admin" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group" "billing" {
  name = "billing"
}

resource "aws_iam_group_policy_attachment" "billing" {
  group      = aws_iam_group.billing.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_policy" "mfa" {
  name = "RequireMFA"
  policy = file("./templates/require-mfa-policy.json")
}

resource "aws_iam_group" "mfa" {
  name = "mfa"
}

resource "aws_iam_group_policy_attachment" "mfa" {
  group      = aws_iam_group.mfa.name
  policy_arn = aws_iam_policy.mfa.arn
}

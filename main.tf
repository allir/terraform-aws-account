provider "aws" {
  region = var.aws_region
}

resource "aws_iam_account_alias" "account_alias" {
  account_alias = var.account_name
}

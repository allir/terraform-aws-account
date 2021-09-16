variable "aws" {
  description = <<EOF
AWS Configuration

Region and Account IDs that to be used. Setting allowed Account IDs will make sure the plan is not applied to the wrong account by mistake.

Example:
{
  region = "us-west-2"
  allowed_account_ids = ["1234567890123"]
}
EOF
  type = object({
    region = string
    allowed_account_ids = set(string)
  })
  default = {
    region = "us-east-1"
    allowed_account_ids = []
  }
}

variable "aws_region" {
  description = "AWS Region"
  type    = string
  default = "us-west-2"
}

variable "account_name" {
  description = "Name/Alias for the AWS account"
  type = string
}

variable "users" {
  description = <<EOF
IAM Users

A map of IAM Users to create in the account.

Example:
{
  admin = {
    name = "Account Admin"
    groups = ["admin", "billing", "mfa"]
    tags = {}
    pgp_key = "keybase:admin_account"
  }
  user = {
    name = "Account User"
    groups = ["mfa"]
    tags = {}
    pgp_key = "keybase:user_account"
  }
}
EOF
  type = map(object({
    name = string
    groups = set(string)
    tags = map(string)
    pgp_key = string
  }))
  default = {}
}

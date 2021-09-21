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

variable "account_name" {
  description = "Name/Alias for the AWS account"
  type = string
}

variable "password_policy" {
  description = "AWS Account Password Policy"
  type = object({
    allow_users_to_change_password = bool
    minimum_password_length        = number
    password_reuse_prevention      = number

    max_password_age               = number
    hard_expiry                    = bool

    require_lowercase_characters   = bool
    require_uppercase_characters   = bool
    require_numbers                = bool
    require_symbols                = bool
  })
  default = {
    allow_users_to_change_password = true
    minimum_password_length        = 12
    password_reuse_prevention      = 0

    max_password_age               = 0
    hard_expiry                    = false

    require_lowercase_characters   = false
    require_uppercase_characters   = false
    require_numbers                = false
    require_symbols                = false
  }
}

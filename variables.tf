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
Create IAM Users

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
    groups = list(string)
    tags = map(string)
    pgp_key = string
  }))
  default = {}
}

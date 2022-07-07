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

resource "aws_iam_user" "users" {
  for_each = var.users
  name = each.key

  tags = merge({
      "Name" = each.value.name
    },
    each.value.tags,
    local.tags
  )

  force_destroy = true
}

resource "aws_iam_user_group_membership" "users" {
  for_each = var.users
  user = aws_iam_user.users[each.key].name

  groups = each.value.groups
}

resource "aws_iam_user_login_profile" "users" {
  for_each = var.users
  user    = aws_iam_user.users[each.key].name
  pgp_key = each.value.pgp_key

  lifecycle {
    ignore_changes = [password_length, password_reset_required, pgp_key]
  }
}

resource "aws_iam_access_key" "users" {
  for_each = var.users
  user    = aws_iam_user.users[each.key].name
  pgp_key = each.value.pgp_key
}

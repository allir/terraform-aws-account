resource "aws_iam_user" "users" {
  for_each = var.users
  name = each.key

  tags = merge(
    {"Name" = each.value.name},
    each.value.tags,
    local.common_tags
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

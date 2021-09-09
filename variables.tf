variable "aws_region" {
  type    = string
  default = "us-west-2"
}

# Name for the S3 Bucket to store terraform state data
variable "account_name" {
  type = string
}

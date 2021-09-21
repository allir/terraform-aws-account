provider "aws" {
  alias= "us-east-1"
  region = "us-east-1"
  allowed_account_ids = var.aws.allowed_account_ids
}

provider "aws" {
  alias= "us-east-2"
  region = "us-east-2"
  allowed_account_ids = var.aws.allowed_account_ids
}

provider "aws" {
  alias= "us-west-1"
  region = "us-west-1"
  allowed_account_ids = var.aws.allowed_account_ids
}

provider "aws" {
  alias= "us-west-2"
  region = "us-west-2"
  allowed_account_ids = var.aws.allowed_account_ids
}
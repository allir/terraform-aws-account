# terraform-aws-account

AWS Account Setup using terraform.

## Using

### State Store and Variables

Set up an S3 Backend and DynamoDB table for state store and locking. It's possible to create one using terraform using [terraform-backend-setup-aws](https://github.com/allir/terraform-backend-setup-aws), which will work as a "one-off" terraform which should itself should store state locally or in version control.

Create a `backend.tf` file either using the generator [terraform-backend-setup-aws](https://github.com/allir/terraform-backend-setup-aws) or manually and fill in the store information.

It should look something like this:

```backend.tf
terraform {
  backend "s3" {
    region = "us-west-2"
    encrypt = true
    bucket = "my-terraform-state-store"
    dynamodb_table = "my-terraform-state-lock"
    key    = "terraform/my-terraform-state.tfstate"
  }
}
```

Create a variables file filling in the configuration for the account, account name, allowed aws account id and more.

Here is an example for `myaccount.tfvars`

```myaccount.tfvars
aws = {
  region = "us-west-2"
  allowed_account_ids = ["123456789012"]
}

account_name = "allir"

cloudtrail = {
  bucket = "my-cloudtrail"
  random_postfix = true
  archive = 90
  expire = 365
}

monitor = {
  root_login = true
  iam_login = true
  email_addresses = ["admin@example.com"]
}

users = {
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
```

These files can be kept in separate version control or the `.gitignore` file can be udpated to allow these to be added to the repo.

### Planning and applying

To see the plan run `terraform plan -var-file=myaccount.tfvars`

To apply and create the resources, run `terraform apply -var-file=myaccount.tfvars` and type in 'yes' when prompted.

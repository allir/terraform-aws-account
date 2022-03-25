variable "cloudtrail" {
  description = "Cloudtrail Settings"
  type = object({
    bucket = string
    random_postfix = bool
    # Number of days for archive/expire lifecycle
    archive = number
    expire = number
  })
  default = {
    bucket = "cloudtrail"
    random_postfix = true
    archive = 90
    expire = 365
  }
}

resource "random_id" "cloudtrail_postfix" {
  count = var.cloudtrail.random_postfix ? 1 : 0
  byte_length = 12
}

resource "aws_s3_bucket" "cloudtrail" {
  provider = aws.us-east-1
  bucket   = var.cloudtrail.random_postfix ? "${var.cloudtrail.bucket}-${random_id.cloudtrail_postfix[0].dec}" : var.cloudtrail.bucket
  
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  tags = merge({
      Name = "Cloudtrail"
    },
    local.common_tags
  )
}

resource "aws_s3_bucket_acl" "cloudtrail" {
  provider = aws.us-east-1
  bucket = aws_s3_bucket.cloudtrail.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  provider = aws.us-east-1
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  provider = aws.us-east-1
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  provider = aws.us-east-1
  bucket = aws_s3_bucket.cloudtrail.id
  
  rule {
    id = "cloudtrail lifecycle rule"
    status = "Enabled"

    transition {
      days          = var.cloudtrail.archive
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = var.cloudtrail.expire
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  provider = aws.us-east-1
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  provider = aws.us-east-1
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket.json

  depends_on = [
    aws_s3_bucket_public_access_block.cloudtrail
  ]
}

data "aws_iam_policy_document" "cloudtrail_bucket" {
  statement {
    sid = "CloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.bucket}",
    ]
  }

  statement {
    sid = "CloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.bucket}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

resource "aws_cloudtrail" "management_events"{
  provider       = aws.us-east-1
  name           = "management-events"
  s3_bucket_name = aws_s3_bucket.cloudtrail.id

  is_multi_region_trail = true
  include_global_service_events = true  

  tags = merge({
      Name = "Management Events Cloudtrail"
    },
    local.common_tags
  )

  depends_on = [
   aws_s3_bucket_policy.cloudtrail,
   aws_s3_bucket_public_access_block.cloudtrail,
  ]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.29.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}

data "aws_vpcs" "nchau-vpc" {
  filter {
    name    = "tag:Name"
    values  = ["nchau-vpc"]
  }
}

resource "random_pet" "name" {
  length    = 3
  separator = "-"
}

resource "aws_s3_bucket" "nc-bucket" {
  bucket        = "${random_pet.name.id}"
  force_destroy = true
  tags          = var.resource_tags
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket    = aws_s3_bucket.nc-bucket.id

  index_document {
    suffix  = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket    = aws_s3_bucket.nc-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket                  = aws_s3_bucket.nc-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [ 
    aws_s3_bucket_public_access_block.bucket,
    aws_s3_bucket_ownership_controls.bucket 
  ]
  bucket = aws_s3_bucket.nc-bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "bucket" {
  depends_on  = [ aws_s3_bucket_acl.bucket ]
  bucket      = aws_s3_bucket.nc-bucket.id
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.nc-bucket.id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_object" "tetris" {
  key       = "index.html"
  bucket    = aws_s3_bucket.nc-bucket.id
  content   = file("${path.module}/assets/index.html")
  content_type = "text/html"
}
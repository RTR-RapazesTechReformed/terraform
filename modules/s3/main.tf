# criação de um id randômico para criação dos buckets
resource "random_id" "bucket_sufixo" {
  byte_length = 4
}
locals {
  timestamp_suffix = formatdate("YYYYMMDDHHmm", timestamp())
}

resource "aws_s3_bucket" "bronze" {
  bucket        = "${var.bucket_prefix}-bronze-${local.timestamp_suffix}-${random_id.bucket_sufixo.hex}"
  force_destroy = true
}

resource "aws_s3_bucket" "silver" {
  bucket        = "${var.bucket_prefix}-silver-${local.timestamp_suffix}-${random_id.bucket_sufixo.hex}"
  force_destroy = true
}

resource "aws_s3_bucket" "gold" {
  bucket        = "${var.bucket_prefix}-gold-${local.timestamp_suffix}-${random_id.bucket_sufixo.hex}"
  force_destroy = true
}
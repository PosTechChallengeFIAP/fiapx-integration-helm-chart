

resource "aws_s3_bucket" "output_bucket" {
  bucket = "fiapx-resulted-zipfiles"

  tags = {
    Name        = "Output"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "output_bucket" {
  bucket = aws_s3_bucket.output_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "output_bucket" {
  bucket = aws_s3_bucket.output_bucket.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.output_bucket
  ]
}

resource "aws_s3_bucket" "uploads_bucket" {
  bucket = "fiapx-uploaded-videos"

  tags = {
    Name        = "Uploads"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "uploads_bucket" {
  bucket = aws_s3_bucket.uploads_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "uploads_bucket" {
  bucket = aws_s3_bucket.uploads_bucket.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.uploads_bucket
  ]
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "terraform-cluster-state-bucket"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
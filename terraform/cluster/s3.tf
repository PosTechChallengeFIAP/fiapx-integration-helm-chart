

resource "aws_s3_bucket" "output_bucket" {
  bucket = "fiapx-resulted-zipfiles-2"

  tags = {
    Name        = "Output"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "output_bucket" {
  bucket = aws_s3_bucket.output_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket" "uploads_bucket" {
  bucket = "fiapx-uploaded-videos-2"

  tags = {
    Name        = "Uploads"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "uploads_bucket" {
  bucket = aws_s3_bucket.uploads_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
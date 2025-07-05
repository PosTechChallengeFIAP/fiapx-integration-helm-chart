

resource "aws_s3_bucket" "output_bucket" {
  bucket = "fiapx-resulted-zipfiles-d27d8e32-c0bd-4f5c-8b97-dd1310b3a289"

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
  bucket = "fiapx-uploaded-videos-d27d8e32-c0bd-4f5c-8b97-dd1310b3a289"

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
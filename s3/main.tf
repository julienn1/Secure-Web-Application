resource "aws_kms_key" "s3_encryption_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10

  tags = {
    Name = "s3-encryption-key"
  }
}



resource "aws_s3_bucket" "app_data" {
  bucket = "app-data-bucket" 
 
  

  tags = {
    Name        = "app-data-bucket"
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id =  aws_kms_key.s3_encryption_key.arn
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "app_data_lifecycle" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    id     = "expire_old_files"
    status = "Enabled"
    #prefix = "uploads/"

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_all" {
  bucket                  = aws_s3_bucket.app_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
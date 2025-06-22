REMEMBER EVERY S3 CODE START WITH  ====     aws_s3_
AFTER aws_s3_ ADD        ====            bucket       /       object     /        bucket_versioning    /   bucket_lifecycle_configuration


#RANDOM WORD FOR S3 NEW NAME
resource "random_id" "server" {
  byte_length = 8
}





#### CREATE BUCKET
resource "aws_s3_bucket" "example" {
  bucket = "bucket-${random_id.server.hex}"     ####WRONG CODE == ( NO HEX)            --  CORRCT CODE== { .hex }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}



#### ADD OBJECT FROM LOCAL PC TO S3
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.example.id
  key    = "ganja"                              #### NAME / FOLDER PATH SHOWN ON S3 LIKE /data/file.txt
  source = "C:/Users/dhair/OneDrive/Desktop/TERRAFORM/S3/backend.tf"        #### LOCAL PATH from my root so backend.tf now gt name given in key so on s3 w see ganja folder

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("path/to/file")                #### check
}




# VERSIONING
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}



# LIFECYCLE 3 RULE APPLIED


resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-config" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioning_example]                           #####change name if need as per ur code value

  bucket = aws_s3_bucket.example.id                                                    #####change name if need as per ur code value

  rule {
    id = "config"

    filter {
      prefix = "config/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    status = "Enabled"
  }
}






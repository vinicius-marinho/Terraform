#------storage/main.tf-----

# Create a random id

resource "random_id" "tf_bucket_id" {
  byte_length = 2
}

# Create the bucket 

resource "aws_s3_bucket" "tf_code" {
  bucket        = "${var.project_name}-${random_id.tf_bucket_id.dec}" ## O campo random_id.tf_bucket_id.dec coloca o número do bucket em decimal
  acl           = "private"                                           ## Defino a canned acl. Quando coloco como private apenas o criador pode acessa-lo
  force_destroy = true                                                ## Destruo o bucket mesmo com files dentro dele

  tags {
    Name = "tf_bucket"
  }
}

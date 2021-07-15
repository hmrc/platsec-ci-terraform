resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = var.boostrap_name
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_key.arn
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

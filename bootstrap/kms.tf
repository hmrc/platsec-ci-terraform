resource "aws_kms_key" "terraform_key" {}

resource "aws_kms_alias" "terraform_key" {
  target_key_id = aws_kms_key.terraform_key.id
  name_prefix   = "alias/${var.boostrap_name}"
}

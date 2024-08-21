resource "aws_kms_key" "terraform_key" {
  deletion_window_in_days = 7
  description             = "Key for assets created during bootstrap of ${var.boostrap_name}"
  enable_key_rotation     = true
  rotation_period_in_days = 90
}

resource "aws_kms_alias" "terraform_key" {
  target_key_id = aws_kms_key.terraform_key.id
  name_prefix   = "alias/${var.boostrap_name}"
}

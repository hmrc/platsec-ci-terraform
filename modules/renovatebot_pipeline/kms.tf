resource "aws_kms_key" "this" {

}

resource "aws_kms_alias" "this" {
  name_prefix   = "alias/${local.name}"
  target_key_id = aws_kms_key.this.id
}
locals {
  name               = "renovatebot"
  primary_repository = var.repositories[0]
  repositories       = join(" ", [for r in var.repositories : format("%s", r)])
}
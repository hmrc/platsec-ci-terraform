output "vpc_config" {
  value = {
    vpc_id               = module.vpc.vpc_id,
    private_subnet_ids   = module.vpc.private_subnets,
    private_subnet_arns  = module.vpc.private_subnet_arns,
    ci_security_group_id = aws_security_group.ci_security_group.id,
  }
}


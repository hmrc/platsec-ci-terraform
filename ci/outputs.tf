output "vpc_config" {
  value = module.networking.vpc_config
}

output "agent_security_group_ids" {
  value = {
    internet          = module.networking.ci_agent_to_internet_sg_id
    service_endpoints = module.networking.ci_agent_to_endpoints_sg_id
  }
}
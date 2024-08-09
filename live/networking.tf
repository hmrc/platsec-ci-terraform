
locals {
  state_bucket             = "platsec-ci20210713082841419000000002"
  vpc_config               = data.terraform_remote_state.ci.outputs.vpc_config
  agent_security_group_ids = data.terraform_remote_state.ci.outputs.agent_security_group_ids
}


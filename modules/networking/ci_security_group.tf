resource "aws_security_group_rule" "allow_tls" {
  security_group_id        = module.artifactory_endpoint_connector.security_group_id
  description              = "Traffic from ci to artifactory"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ci_security_group.id
}

resource "aws_security_group" "ci_security_group" {
  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id

  egress {
    description     = "Traffic from ci to Artifactory"
    from_port       = 443
    protocol        = "tcp"
    to_port         = 443
    security_groups = [module.artifactory_endpoint_connector.security_group_id]
  }

  egress {
    description     = "Traffic to aws endpoints"
    from_port       = 443
    protocol        = "tcp"
    to_port         = 443
    prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
  }

  egress {
    description     = "Traffic to interface endpoints"
    from_port       = 443
    protocol        = "tcp"
    to_port         = 443
    security_groups = [aws_security_group.endpoints.id]
  }
}



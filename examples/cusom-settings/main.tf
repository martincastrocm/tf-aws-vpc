data "aws_region" "current" {}
################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../"
  name   = "custom-settings-vpc"

  vpc = {
    cidr = "10.100.0.0/16"
    tags = { "key_vpc" : "value_vpc" }
  }

  subnets = {
    azs = ["${data.aws_region.current.name}b", "${data.aws_region.current.name}d"]
    public = {
      cidrs                   = ["10.100.101.0/24", "10.100.102.0/24"]
      suffix                  = "public-custom"
      map_public_ip_on_launch = true
    }
    private = {
      cidrs  = ["10.100.103.0/24", "10.100.103.0/24"]
      suffix = "private-custom"
      inbound_acl_rules = [
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
        },
        {
          rule_number = 1
          rule_action = "deny"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
        },
      ]
      outbound_acl_rules = [
        {
          rule_number = 1
          rule_action = "deny"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
        },
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 1024
          to_port     = 65535
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
        },
      ]
    }
  }

  tags = {
    example = "custom-settings-vpc"
  }
}

output "azs" {
  description = "AZs deployed"
  value       = local.azs
}

################################################################################
# VPC
################################################################################

output "vpc" {
  description = "VPC information"
  value = {
    id         = aws_vpc.this.id
    arn        = aws_vpc.this.arn
    cidr_block = aws_vpc.this.cidr_block
  }
}

################################################################################
# Internet Gateway
################################################################################

output "igw_id" {
  description = "Internet Gateway information"
  value = {
    id  = aws_internet_gateway.this.id
    arn = aws_internet_gateway.this.arn
  }
}

################################################################################
# Publiс Subnets
################################################################################

output "public_subnets_az_map" {
  description = "AZ-public subnet map information"
  value = { for k, v in aws_subnet.public : k =>
    {
      id         = v.id
      arn        = v.arn
      cidr_block = v.cidr_block
    }
  }
}

################################################################################
# Private Subnets
################################################################################

output "private_subnets_az_map" {
  description = "AZ-private subnet map information"
  value = { for k, v in aws_subnet.private : k =>
    {
      id         = v.id
      arn        = v.arn
      cidr_block = v.cidr_block
    }
  }
}

################################################################################
# NAT Gateway
################################################################################

output "nat_gw_az_map" {
  description = "AZ-NAT Gateway map information"
  value = { for k, v in aws_nat_gateway.this : k =>
    {
      id             = v.id
      public_ip      = v.public_ip
      association_id = v.association_id
    }
  }
}

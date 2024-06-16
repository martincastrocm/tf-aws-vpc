

locals {
  azs                   = length(var.subnets.azs) > 0 ? var.subnets.azs : slice(data.aws_availability_zones.available.names, 0, var.subnets.az_number)
  public_subnets_cidrs  = zipmap(local.azs, length(var.subnets.public.cidrs) > 0 ? var.subnets.public.cidrs : [for k, v in local.azs : cidrsubnet(var.vpc.cidr, 8, k)])
  private_subnets_cidrs = zipmap(local.azs, length(var.subnets.private.cidrs) > 0 ? var.subnets.private.cidrs : [for k, v in local.azs : cidrsubnet(var.vpc.cidr, 8, k + length(local.azs))])
}

data "aws_availability_zones"       "available" {}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {

  cidr_block = var.vpc.cidr

  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  enable_dns_support   = var.vpc.enable_dns_support

  tags = merge(
    { "Name" = var.name },
    var.vpc.tags,
    var.tags
  )
}


################################################################################
# Publiс Subnets
################################################################################

resource "aws_subnet" "public" {
  for_each = toset(local.azs)

  availability_zone       = each.key
  cidr_block              = local.public_subnets_cidrs[each.key]
  map_public_ip_on_launch = var.subnets.public.map_public_ip_on_launch
  vpc_id                  = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-${var.subnets.public.suffix}-${each.key}"
    },
    var.tags,
    var.subnets.public.tags,
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.name}-${var.subnets.public.suffix}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  for_each = toset(local.azs)

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  for_each = toset(local.azs)

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = var.name },
    var.tags,
  )
}

################################################################################
# Public Network ACLs
################################################################################

resource "aws_network_acl" "public" {

  vpc_id     = aws_vpc.this.id
  subnet_ids = [for k, v in aws_subnet.public : v.id]

  tags = merge(
    {
      "Name" = "${var.name}-${var.subnets.public.suffix}"
    },
    var.tags
  )
}

resource "aws_network_acl_rule" "public_inbound" {
  for_each       = { for r in var.subnets.public.inbound_acl_rules : r.rule_number => r }
  network_acl_id = aws_network_acl.public.id

  egress      = false
  rule_number = each.value.rule_number
  rule_action = each.value.rule_action
  from_port   = try(each.value.from_port, null)
  to_port     = try(each.value.to_port, null)
  icmp_code   = try(each.value.icmp_code, null)
  icmp_type   = try(each.value.icmp_type, null)
  protocol    = each.value.protocol
  cidr_block  = try(each.value.cidr_block, null)
}

resource "aws_network_acl_rule" "public_outbound" {
  for_each = { for r in var.subnets.public.outbound_acl_rules : r.rule_number => r }

  network_acl_id = aws_network_acl.public.id

  egress      = true
  rule_number = each.value.rule_number
  rule_action = each.value.rule_action
  from_port   = try(each.value.from_port, null)
  to_port     = try(each.value.to_port)
  icmp_code   = try(each.value.icmp_code, null)
  icmp_type   = try(each.value.icmp_type, null)
  protocol    = each.value.protocol
  cidr_block  = try(each.value.cidr_block, null)
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private" {
  for_each = toset(local.azs)

  availability_zone = each.key
  cidr_block        = local.private_subnets_cidrs[each.key]
  vpc_id            = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-${var.subnets.private.suffix}-${each.key}"
    },
    var.tags,
    var.subnets.private.tags,
  )
}

resource "aws_route_table" "private" {
  for_each = toset(local.azs)

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.name}-${var.subnets.private.suffix}-${each.key}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  for_each = toset(local.azs)

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route" "private_nat_gateway" {
  for_each = toset(local.azs)

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id

  timeouts {
    create = "5m"
  }
}

################################################################################
# NAT Gateway
################################################################################
resource "aws_eip" "nat" {
  for_each = toset(local.azs)
  domain   = "vpc"

  tags = merge(
    {
      "Name" = "${var.name}-${each.key}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.azs)

  subnet_id     = aws_subnet.public[each.key].id
  allocation_id = aws_eip.nat[each.key].id

  tags = merge(
    {
      "Name" = "${var.name}-${each.key}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}


################################################################################
# Private Network ACLs
################################################################################

resource "aws_network_acl" "private" {

  vpc_id     = aws_vpc.this.id
  subnet_ids = [for k, v in aws_subnet.private : v.id]

  tags = merge(
    {
      "Name" = "${var.name}-${var.subnets.private.suffix}"
    },
    var.tags
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  for_each       = { for r in var.subnets.private.inbound_acl_rules : r.rule_number => r }
  network_acl_id = aws_network_acl.private.id

  egress      = false
  rule_number = each.value.rule_number
  rule_action = each.value.rule_action
  from_port   = try(each.value.from_port, null)
  to_port     = try(each.value.to_port, null)
  icmp_code   = try(each.value.icmp_code, null)
  icmp_type   = try(each.value.icmp_type, null)
  protocol    = each.value.protocol
  cidr_block  = try(each.value.cidr_block, null)
}

resource "aws_network_acl_rule" "private_outbound" {
  for_each = { for r in var.subnets.private.outbound_acl_rules : r.rule_number => r }

  network_acl_id = aws_network_acl.private.id

  egress      = true
  rule_number = each.value.rule_number
  rule_action = each.value.rule_action
  from_port   = try(each.value.from_port, null)
  to_port     = try(each.value.to_port)
  icmp_code   = try(each.value.icmp_code, null)
  icmp_type   = try(each.value.icmp_type, null)
  protocol    = each.value.protocol
  cidr_block  = try(each.value.cidr_block, null)
}

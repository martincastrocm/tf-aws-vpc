output "azs" {
  value = module.vpc.azs
}

output "vpc" {
  value = module.vpc.vpc
}

output "igw_id" {
  value = module.vpc.igw_id
}

output "public_subnets_az_map" {
  value = module.vpc.public_subnets_az_map
}

output "private_subnets_az_map" {
  value = module.vpc.private_subnets_az_map
}

output "nat_gw_az_map" {
  value = module.vpc.nat_gw_az_map
}


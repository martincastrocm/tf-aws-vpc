# Simple VPC
Configuration in this directory creates set of VPC resources which may be sufficient for development environment.

## Resources created
- 1 a VPC created with the default VPC CIDR
- 1 public and 1 private subnet in the first az of the current region.
- 1 Internet Gateway.
- 1 NAT Gateway.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.
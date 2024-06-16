# Custom Settings
Configuration in this directory creates set of VPC resources which may be sufficient for development environment.

## Resources created
- 1 a VPC created with the configurations provided in the variable `vpc`.
- 2 public and 2 private subnets in the az list provided by in `subnets.az` and the configurations provided in `subnets.public` and `subnets.private` respectively.
- 1 Internet Gateway.
- 2 NAT Gateways: one per az.

## Usage
To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc" {
  description = <<EOF
VPC configuration. This object contains the following parameters:
- cidr: The CIDR block for the VPC. Defaults to "10.0.0.0/16".
- enable_dns_hostnames: Whether to enable DNS hostnames for instances within the VPC. Defaults to true.
- enable_dns_support: Whether to enable DNS support within the VPC. Defaults to true.
- tags: A map of tags to assign to the VPC. Defaults to an empty map.
EOF
  type = object({
    cidr                 = optional(string, "10.0.0.0/16")
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)
    tags                 = optional(map(string), {})
  })
  default = {
    cidr                 = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags                 = {}
  }
}

variable "subnets" {
  description = <<EOF
Subnets configuration. This object contains the following parameters:
- azs: A list of availability zones to create subnets in. Takes precedence over az_number.
- az_number: The number of availability zones to use if azs is not provided.
- public: Configuration for public subnets.
  - cidrs: A list of CIDR blocks for the public subnets.
  - suffix: A suffix to add to the name of the public subnets.
  - map_public_ip_on_launch: Whether to assign a public IP to instances launched in the public subnets. 
  - tags: A map of tags to assign to the public subnets. Defaults to an empty map.
  - inbound_acl_rules: A list of inbound network ACL rules for the public subnets.
  - outbound_acl_rules: A list of outbound network ACL rules for the public subnets.
- private: Configuration for private subnets.
  - cidrs: A list of CIDR blocks for the private subnets.
  - suffix: A suffix to add to the name of the private subnets.
  - map_public_ip_on_launch: Whether to assign a public IP to instances launched in the private subnets.
  - tags: A map of tags to assign to the private subnets.
  - inbound_acl_rules: A list of inbound network ACL rules for the private subnets.
  - outbound_acl_rules: A list of outbound network ACL rules for the private subnets.
EOF
  type = object({
    azs       = optional(list(string), [])
    az_number = optional(number, 1)
    public = optional(object({
      cidrs                   = optional(list(string), [])
      suffix                  = optional(string, "public")
      map_public_ip_on_launch = optional(bool, false)
      tags                    = optional(map(string), {})
      inbound_acl_rules = optional(list(map(string)), [
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
        },
      ])
      outbound_acl_rules = optional(list(map(string)), [
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
        },
      ])
      }),
      {
        cidrs                   = []
        suffix                  = "public"
        map_public_ip_on_launch = false
        tags                    = {}
        inbound_acl_rules = [
          {
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          },
        ]
        outbound_acl_rules = [
          {
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          },
        ]
      }
    )
    private = optional(object({
      cidrs                   = optional(list(string), [])
      suffix                  = optional(string, "private")
      map_public_ip_on_launch = optional(bool, false)
      tags                    = optional(map(string), {})
      inbound_acl_rules = optional(list(map(string)), [
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
        },
      ])
      outbound_acl_rules = optional(list(map(string)), [
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
        },
      ])
      }),
      {
        cidrs  = []
        suffix = "private"
        tags   = {}
        inbound_acl_rules = [
          {
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          },
        ]
        outbound_acl_rules = [
          {
            rule_number = 100
            rule_action = "allow"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_block  = "0.0.0.0/0"
          },
        ]
      }
    )
  })
  default = {
    azs       = []
    az_number = 1
    public = {
      cidrs                   = []
      suffix                  = "public"
      map_public_ip_on_launch = false
      tags                    = {}
      inbound_acl_rules = [
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
        },
      ]
      outbound_acl_rules = [
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
        },
      ]
    }
    private = {
      cidrs                   = []
      suffix                  = "private"
      map_public_ip_on_launch = false
      tags                    = {}
      inbound_acl_rules = [
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
        },
      ]
      outbound_acl_rules = [
        {
          rule_number = 100
          rule_action = "allow"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_block  = "0.0.0.0/0"
        },
      ]
    }
  }
}


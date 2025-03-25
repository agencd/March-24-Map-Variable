terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.92.0"
    }
  }
}

provider "aws" {}

variable "prefix" {
  type = string
  default = "project-delta"
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

variable "subnet_cidr_block" {
  type = string
  default = "10.0.1.0/24"
}

# resource_type.resource_name/logical_name.attribute
# aws_vpc.main.id
# Terraform Resource Address
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block

  tags = {
    Name = "${var.prefix}-subnet"
  }
}


variable "security_groups" {
  type = object({
    name_of_sg = optional(string)
    description = optional(string)
    ingress = optional(list(object(
      {
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = optional(list(string), ["0.0.0.0/0"])
        description = optional(string)
      }
    )))
    egress = optional(list(object(
      {
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = optional(list(string), ["0.0.0.0/0"])
        description = optional(string)
      }
    )))
  })
  default = {}
}

# 1. If i wanted to have empty string value what should be my default ? ""
# 2. If i wanted to have empty list value what should be my default ? []
# 3. If i wanted to have empty map value what should be my default ? {}
resource "aws_security_group" "allow_ssh" {
  name        = var.security_groups.name_of_sg
  description = var.security_groups.description
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.security_groups.ingress != null ? var.security_groups.ingress : []
    content {
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  dynamic "egress" {
    for_each = var.security_groups.egress != null ? var.security_groups.egress : []
    content {
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = {
    Name = "${var.prefix}-sg"
  }
}


variable "allow_ssh" {
  type = bool
  default = false
}


# variable "allow_ssh_count" {
#   type = number
#   default = 1
# }

            #  `is true` means `?`   `otherwise` means `:`
            # if var.allow_ssh is true create 1 otherwise create 0
            #  count             = var.allow_ssh ? 1 : 0

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# resource "aws_instance" "web" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"
#   subnet_id = aws_subnet.main.id
#   vpc_security_group_ids = [aws_security_group.allow_ssh.id]

#   tags = {
#     Name = "${var.prefix}-ec2"
#   }
# }

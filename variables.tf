data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "just-boxey-things"
    workspaces = {
      name = "aws-network"
    }
  }
}

data "aws_vpc" "vpc" {
  id = data.terraform_remote_state.vpc.outputs.main.id
}



variable "ssh_sg_name" {
  description = "Name for the Security Group that allows SSH"
  type        = string
  default     = "ssh-sg"
}


variable "internet_facing_elb_name_sg_name" {
  description = "Name for the Internet Facing Elastic Load Balancer"
  type        = string
  default     = "internet-facing-elb-sg"
}


variable "web_servers_sg_name" {
  description = "Name for the Security Group Controlling Traffic to Web Servers"
  type        = string
  default     = "web-servers-sg"
}


variable "security_group_tags" {
  type = map(string)
  default = {
    "Type" = "Security Groups"
  }
}

locals {
  tags = merge(var.security_group_tags, { for k, v in data.aws_vpc.vpc.tags: k=>v if ! strcontains(k, "Name")})
}


data "aws_security_groups" "web_server_security_groups" {
  
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name = "group-name"
    values = [ "ssh-sg", "web-servers-sg*" ]
  }
  
}
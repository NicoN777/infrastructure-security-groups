provider "aws" {
  region = "us-east-1"
}


resource "aws_security_group" "ssh_sg" {
    name = var.ssh_sg_name
    description = "SSH Security Group"
    vpc_id      = data.aws_vpc.vpc.id

    ingress {
        description      = "SSH from Anywhere"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = local.tags
}

resource "aws_ec2_tag" "ssh_sg_tag" {
  resource_id = aws_security_group.ssh_sg.id
  key         = "Name"
  value       = aws_security_group.ssh_sg.name
  depends_on = [ aws_security_group.ssh_sg ]
}


module "internet_facing_elb_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = var.internet_facing_elb_name_sg_name
  description = "Control Traffic to Internet Facing Elastic Load Balancer"
  vpc_id      = data.aws_vpc.vpc.id
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.tags
}


module "web_servers_sg" {
  source     = "terraform-aws-modules/security-group/aws"
  name       = var.web_servers_sg_name
  vpc_id     = data.aws_vpc.vpc.id
  depends_on = [module.internet_facing_elb_sg, aws_security_group.ssh_sg]
  ingress_with_source_security_group_id = [
    {
        rule                     = "https-443-tcp"
        source_security_group_id = module.internet_facing_elb_sg.security_group_id
    },
    {
        rule                     = "http-80-tcp"
        source_security_group_id = module.internet_facing_elb_sg.security_group_id
    },
    {
        rule = "ssh-tcp"
        source_security_group_id = aws_security_group.ssh_sg.id
    }
  ]

  tags = local.tags
}


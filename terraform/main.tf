provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "jenkins_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins"
  description = "Security group for Jenkins"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp","https-443-tcp"]

  ingress_cidr_blocks = ["${var.ssh_ingress_cidr_blocks}"]
  ingress_rules       = ["ssh-tcp"]

  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"] 
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins"
  instance_count = 1

  ami                         = "${lookup(var.amis, var.region)}"
  instance_type               = "t2.micro"
  subnet_id                   = "${module.vpc.public_subnets[0]}"
  vpc_security_group_ids      = ["${module.jenkins_sg.this_security_group_id}"]
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Platform    = "ubuntu"
  }
}

resource "aws_eip" "lb" {
  instance = "${module.ec2.id[0]}"
  vpc      = true
}

output "jenkins_eip" {
  value = "${aws_eip.lb.public_ip}"
}


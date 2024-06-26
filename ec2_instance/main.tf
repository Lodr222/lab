terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
		}
	}
}

provider "aws" {
	region = "us-east-1"
	shared_config_files = ["./config"]
	shared_credentials_files = ["./credentials"]
	profile = "default"
}

data "aws_ami" "amazon_linux" {
	most_recent = true
	filter {
		name = "name"
		values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
	}
	owners = ["amazon"]
}

resource "aws_instance" "web" {
	ami = data.aws_ami.amazon_linux.id
	instance_type = "t2.micro"
	key_name = "Lab1"
	vpc_security_group_ids = [aws_security_group.web_sg.id]
	tags = {
		"Name" = "Lab2-EC2-Lavryk"
	}

	user_data = <<-EOF
		#!/bin/bash
		sudo yum update -y
		sudo yum install httpd -y
		sudo systemctl start httpd
		sudo systemctl enable httpd
		echo "<html><h1>やった! Jenkins pipeline works! IMIzm-23-1 Lavryk Dmytro</h1></html>" > /var/www/html/index.html
		EOF
}
resource "aws_security_group" "web_sg" {
	name = "Lab2-EC2-Lavryk-SG"
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 22
		to_port =22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

output "website_endpoint" {
	value = aws_instance.web.public_dns
}

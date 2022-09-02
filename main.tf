terraform {
  cloud {
    organization = "omarosman23"

    workspaces {
      name = "juno-node"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

}

provider "aws" {
  region = "us-west-2"
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqIeoyluNk/fW9w/7gBoOW3bCZrZf2f4dhPgWtGbJ/HukKCyzkxa2ugKlQWkTmAYX848UI6onhWF9Py42kiF7XVUiTXxHto1KSBmW1jM7vFK2zF/c/qcLIpsOfOh9kIMXLnk009mloMCtzGByCSKcBG63RhEdQ+Zqkxifm+2R6E6ryLauQouDXRYYr/TXqZmFFmftNhABXJKWWbAtkyBkm86pO2L1E+GxGcKoi7jjSi0wwWKocQEDL1akHrlWh4r8iBTeei0ycO38bYlnbSr3mIQCdIEifWbgVFbJ5CrPsEVI1OJQy987ZhtwJcE3eYTowzLYcr+jFYMOd8RdiBcYr"
}


data "template_file" "user_data" {
  template = "${file("./userdata.yaml")}"
}

resource "aws_instance" "web" {
  
  ami           = "ami-0d70546e43a941d70"
  instance_type = "t2.large"
  key_name = "${aws_key_pair.deployer.key_name}"
  user_data = data.template_file.user_data.rendered
  vpc_security_group_ids = [aws_security_group.sg_web.id]


  tags = {
    Name = "MyServer"
  }

 
}


output "public_ip" {  
  description = "Public IP address of the EC2 instance"
  value = aws_instance.web.public_ip
}

data "aws_vpc" "main" {
  id = "vpc-06f6608585199b584"
}


resource "aws_security_group" "sg_web" {
  name        = "sg_web"
  description = "Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  },
    {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }

]
  egress = [
    { 
    description      = "outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
  }

]

}




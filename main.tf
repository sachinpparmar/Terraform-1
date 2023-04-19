terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_instance" "app_server" {
  ami             = "ami-0277b52859bac6f4b"
  instance_type   = "t2.micro"
  key_name        = "JainwindowsServer"
  user_data	= file("file.sh")
  security_groups = [ "Docker" ]

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_security_group" "Docker" {
  tags = {
    type = "terraform-test-security-group"
  }
}
------------------------------------
  
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami             = "ami-06e46074ae430fba6"
  instance_type   = "t2.micro"
  #key_name        = "JainwindowsServer"
  user_data       = file("file.sh")
  security_groups = [aws_security_group.Docker.name]

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_security_group" "Docker" {
  description = "Security group for Docker containers"
  tags = {
    type = "terraform-test-security-group"
  }
}

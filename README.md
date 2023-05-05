# Terraform


provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}
# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-KEY" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "TFkey"
}

resource "aws_security_group" "MVRC" {
  name_prefix = "MVRC"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "MVRC-1" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"

  tags = {
    Name = "MVRC-instance"
  }

  vpc_security_group_ids = [aws_security_group.MVRC.id]

  user_data = <<-EOF
    #!/bin/sh
    apt-get update
    apt-get install -y docker.io
    sudo systemctl start docker
    sudo usermod -a -G docker $USER
    sudo systemctl enable docker
    sudo apt install -y git
    apt-get install -y docker-compose
    

    # Create Dockerfile and build image
    docker build -t my-apache-image - <<DOCKERFILE
    FROM ubuntu:latest
    RUN apt-get update && apt-get install -y apache2
    CMD ["apache2ctl", "-DFOREGROUND"]
    DOCKERFILE

    # Run container from the built image
    docker run -d -p 80:80 my-apache-image
    
 EOF

}

output "public_ip" {
  value = aws_instance.MVRC-1.public_ip
}

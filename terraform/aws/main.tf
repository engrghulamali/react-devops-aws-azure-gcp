terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------
# Get latest Ubuntu 22.04 AMI
# -----------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# -----------------------------
# IAM Role for SSM
# -----------------------------
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.name_prefix}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.name_prefix}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# -----------------------------
# Security Group
# -----------------------------
resource "aws_security_group" "sg" {
  name        = "${var.name_prefix}-sg"
  description = "Allow HTTP/SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-sg" }
}

# -----------------------------
# Key Pair (Optional)
# -----------------------------
resource "aws_key_pair" "kp" {
  count      = var.use_keypair ? 1 : 0
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# -----------------------------
# EC2 Instance
# -----------------------------
resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = var.use_keypair ? aws_key_pair.kp[0].key_name : null
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id

  user_data = templatefile("${path.module}/userdata.tpl", {
    docker_image      = var.docker_image
    docker_username   = var.dockerhub_username
    docker_password   = var.dockerhub_password
  })

  tags = { Name = "${var.name_prefix}-instance" }
}

# -----------------------------
# Outputs
# -----------------------------
output "public_ip" {
  value = aws_instance.app.public_ip
}

output "public_dns" {
  value = aws_instance.app.public_dns
}

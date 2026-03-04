terraform {
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

# Find the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "minecraft_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for the Minecraft server"

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_ips
    description = "Allow SSH access"
  }

  # Allow Minecraft client access
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Minecraft clients"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_key_pair" "minecraft_key" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_ebs_volume" "minecraft_data" {
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size_gb
  type              = "gp3"

  tags = {
    Name = "${var.project_name}-data"
  }
}

resource "aws_instance" "minecraft_server" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.minecraft_key.key_name
  vpc_security_group_ids      = [aws_security_group.minecraft_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  availability_zone           = var.availability_zone
  associate_public_ip_address = true

  # Ensure root volume is preserved on stop
  instance_initiated_shutdown_behavior = "stop"

  user_data = file("${path.module}/scripts/user_data.sh")

  tags = {
    Name = var.project_name
  }
}

resource "aws_volume_attachment" "minecraft_data_attachment" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.minecraft_server.id
  volume_id   = aws_ebs_volume.minecraft_data.id
}

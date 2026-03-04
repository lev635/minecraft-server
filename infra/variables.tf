variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "A unique name for the project used for tagging and naming resources."
  type        = string
  default     = "minecraft-server"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file to be used for the EC2 instance."
  type        = string
  # Example: "~/.ssh/id_rsa.pub"
}

variable "ssh_allowed_ips" {
  description = "A list of CIDR blocks to allow SSH access from."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ec2_instance_type" {
  description = "The EC2 instance type for the Minecraft server."
  type        = string
  default     = "t3.medium"
}

variable "ebs_volume_size_gb" {
  description = "The size of the EBS volume for Minecraft world data in GB."
  type        = number
  default     = 20
}

variable "availability_zone" {
  description = "The Availability Zone to launch the resources in."
  type        = string
  default     = "ap-northeast-1a"
}

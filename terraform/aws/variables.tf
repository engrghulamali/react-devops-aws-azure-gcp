variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "name_prefix" {
  type    = string
  default = "portfolio"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "docker_image" {
  type        = string
  description = "Docker Hub image (e.g. username/repo:tag)"
}

variable "use_keypair" {
  type    = bool
  default = false
}

variable "key_name" {
  type    = string
  default = ""
}

variable "public_key_path" {
  type    = string
  description = "ssh key"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your IP in CIDR format to allow SSH (e.g. 1.2.3.4/32)"
  default     = "0.0.0.0/0" # change to your ip
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "Optional: VPC ID if you already have one. Leave empty to use default VPC and subnet"
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "Optional: subnet id (recommended)"
}

variable "dockerhub_username" {
  type    = string
  description = "Docker Hub username"
}

variable "dockerhub_password" {
  type      = string
  description = "Docker Hub password"
  sensitive = true
}

variable "enable_https" {
  type    = bool
  default = false
}

variable "domain_name" {
  type    = string
  default = ""
}

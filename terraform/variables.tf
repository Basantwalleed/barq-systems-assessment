variable "aws_region" {
  description = "AWS region for the Kubernetes infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource tags"
  type        = string
  default     = "aws-kubernetes-project"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet for the Kubernetes EC2 instances"
  type        = string
  default     = "10.20.1.0/24"
}

variable "database_subnet_a_cidr" {
  description = "Private database subnet in Availability Zone A"
  type        = string
  default     = "10.20.2.0/24"
}

variable "database_subnet_b_cidr" {
  description = "Private database subnet in Availability Zone B"
  type        = string
  default     = "10.20.3.0/24"
}

variable "availability_zone_a" {
  description = "First Availability Zone"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_b" {
  description = "Second Availability Zone"
  type        = string
  default     = "us-east-1b"
}

variable "approved_ssh_cidr" {
  description = "Approved public IPv4 address for SSH, in CIDR notation"
  type        = string
  default     = "156.193.25.124/32"
}

variable "instance_type" {
  description = "EC2 instance type for Kubernetes nodes"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name for SSH access"
  type        = string
  default     = "aws-kubernetes-project"
}

variable "db_instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
  default     = "kubernetesdb"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "k8sadmin"
}

variable "db_password" {
  description = "PostgreSQL master password; supply through a secure variable source"
  type        = string
  sensitive   = true
  default     = null
}
variable "common_tags" {
  description = "Tags applied to project resources"
  type        = map(string)
  default = {
    Project   = "aws-kubernetes-project"
    ManagedBy = "Terraform"
  }
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID for Kubernetes nodes"
  type        = string
  default     = "ami-0856027a77429315a"
}
variable "db_final_snapshot_identifier" {
  description = "Identifier for the final RDS snapshot"
  type        = string
  default     = "aws-kubernetes-project-postgres-final"
}


variable "elasticache_auth_token" {
  description = "Private authentication token for the managed cache"
  type        = string
  sensitive   = true
  nullable    = false
  validation {
    condition     = length(var.elasticache_auth_token) >= 16 && length(var.elasticache_auth_token) <= 128
    error_message = "The cache authentication token must be 16 to 128 characters."
  }
}

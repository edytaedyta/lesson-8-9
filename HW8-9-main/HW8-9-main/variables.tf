variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cicd-pipeline"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# S3 Backend variables
variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "cicd-terraform-state-${local.timestamp}"
}

variable "state_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "cicd-terraform-locks"
}

# VPC variables
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ECR variables
variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "django-app"
}

variable "ecr_image_tag_mutability" {
  description = "ECR image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "ECR scan on push"
  type        = bool
  default     = true
}

# EKS variables
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_group_desired_size" {
  description = "EKS node group desired size"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "EKS node group minimum size"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "EKS node group maximum size"
  type        = number
  default     = 4
}

variable "node_group_instance_types" {
  description = "EKS node group instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

# Jenkins variables
variable "jenkins_namespace" {
  description = "Jenkins namespace"
  type        = string
  default     = "jenkins"
}

variable "jenkins_admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "docker_username" {
  description = "Docker username"
  type        = string
  sensitive   = true
}

variable "docker_password" {
  description = "Docker password"
  type        = string
  sensitive   = true
}

variable "docker_email" {
  description = "Docker email"
  type        = string
}

# Argo CD variables
variable "argocd_namespace" {
  description = "Argo CD namespace"
  type        = string
  default     = "argocd"
}

variable "argocd_admin_password" {
  description = "Argo CD admin password"
  type        = string
  sensitive   = true
}

variable "django_app_repo" {
  description = "Django app repository URL"
  type        = string
}

variable "django_app_path" {
  description = "Django app path in repository"
  type        = string
  default     = "charts/django-app"
}

variable "django_app_branch" {
  description = "Django app branch"
  type        = string
  default     = "main"
}

locals {
  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}

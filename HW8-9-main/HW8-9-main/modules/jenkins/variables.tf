variable "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Base64 encoded CA certificate"
  type        = string
  sensitive   = true
}

variable "cluster_token" {
  description = "Kubernetes API token"
  type        = string
  sensitive   = true
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "jenkins_release_name" {
  description = "Helm release name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "jenkins_chart_repository" {
  description = "Helm repository URL for Jenkins"
  type        = string
  default     = "https://charts.jenkins.io"
}

variable "jenkins_chart_name" {
  description = "Helm chart name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "jenkins_chart_version" {
  description = "Helm chart version for Jenkins"
  type        = string
  default     = "3.10.0"
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

variable "docker_registry" {
  description = "Docker registry URL"
  type        = string
  default     = "https://index.docker.io/v1/"
}

variable "docker_username" {
  description = "Docker registry username"
  type        = string
}

variable "docker_password" {
  description = "Docker registry password"
  type        = string
  sensitive   = true
}

variable "docker_email" {
  description = "Docker registry email"
  type        = string
}

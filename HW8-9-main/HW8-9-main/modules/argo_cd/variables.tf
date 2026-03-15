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
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "argo_cd_release_name" {
  description = "Helm release name for Argo CD"
  type        = string
  default     = "argo-cd"
}

variable "argo_cd_chart_repository" {
  description = "Helm repository URL for Argo CD"
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}

variable "argo_cd_chart_name" {
  description = "Helm chart name for Argo CD"
  type        = string
  default     = "argo-cd"
}

variable "argo_cd_chart_version" {
  description = "Helm chart version for Argo CD"
  type        = string
  default     = "5.46.8"
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
  description = "Path to Django app in repository"
  type        = string
  default     = "charts/django-app"
}

variable "django_app_branch" {
  description = "Django app repository branch"
  type        = string
  default     = "main"
}

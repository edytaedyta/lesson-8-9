variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "django-app"
}

variable "image_tag_mutability" {
  description = "Image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

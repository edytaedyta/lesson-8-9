output "argo_cd_namespace" {
  description = "Argo CD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argo_cd_release_name" {
  description = "Argo CD release name"
  value       = helm_release.argo_cd.name
}

output "argo_cd_admin_user" {
  description = "Argo CD admin username"
  value       = "admin"
}

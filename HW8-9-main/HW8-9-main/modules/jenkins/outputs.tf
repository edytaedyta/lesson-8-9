output "jenkins_service_name" {
  description = "Jenkins service name"
  value       = "${helm_release.jenkins.name}-controller"
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "jenkins_admin_user" {
  description = "Jenkins admin username"
  value       = var.jenkins_admin_user
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }

  depends_on = []
}

resource "kubernetes_secret" "docker_credentials" {
  metadata {
    name      = "dockerhub"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  type = "kubernetes.io/dockercfg"

  data = {
    ".dockercfg" = jsonencode({
      "${var.docker_registry}" = {
        username = var.docker_username
        password = var.docker_password
        email    = var.docker_email
      }
    })
  }
}

resource "helm_release" "jenkins" {
  name            = var.jenkins_release_name
  repository      = var.jenkins_chart_repository
  chart           = var.jenkins_chart_name
  namespace       = kubernetes_namespace.jenkins.metadata[0].name
  version         = var.jenkins_chart_version
  create_namespace = false

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "persistence.storageClassName"
    value = "gp2"
  }

  set {
    name  = "serviceAccount.name"
    value = "jenkins"
  }

  set {
    name  = "controller.adminUser"
    value = var.jenkins_admin_user
  }

  set_sensitive {
    name  = "controller.adminPassword"
    value = var.jenkins_admin_password
  }

  depends_on = [kubernetes_namespace.jenkins, kubernetes_secret.docker_credentials]
}

resource "helm_release" "jenkins_git_plugin" {
  count      = 0  # Will be managed via Jenkins Helm chart values
  name       = "jenkins-git-plugin"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  depends_on = [helm_release.jenkins]
}

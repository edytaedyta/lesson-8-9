resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo_cd" {
  name            = var.argo_cd_release_name
  repository      = var.argo_cd_chart_repository
  chart           = var.argo_cd_chart_name
  namespace       = kubernetes_namespace.argocd.metadata[0].name
  version         = var.argo_cd_chart_version
  create_namespace = false

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(var.argocd_admin_password)
  }

  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "argocd_applications" {
  name            = "argo-applications"
  chart           = "${path.module}/charts"
  namespace       = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false

  values = [
    templatefile("${path.module}/charts/values.yaml", {
      django_app_repo = var.django_app_repo
      django_app_path = var.django_app_path
      django_app_branch = var.django_app_branch
    })
  ]

  depends_on = [helm_release.argo_cd]
}

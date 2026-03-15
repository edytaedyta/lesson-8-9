module "s3_backend" {
  source = "./modules/s3-backend"

  state_bucket_name   = var.state_bucket_name
  dynamodb_table_name = var.state_table_name
  environment         = var.environment
}

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = "${var.project_name}-eks"
  kubernetes_version  = var.kubernetes_version
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  desired_size        = var.node_group_desired_size
  min_size            = var.node_group_min_size
  max_size            = var.node_group_max_size
  instance_types      = var.node_group_instance_types
}

module "jenkins" {
  source = "./modules/jenkins"

  cluster_endpoint           = module.eks.cluster_endpoint
  cluster_ca_certificate     = module.eks.cluster_ca_certificate
  cluster_token              = data.aws_eks_cluster_auth.cluster.token
  namespace                  = var.jenkins_namespace
  jenkins_admin_user         = var.jenkins_admin_user
  jenkins_admin_password     = var.jenkins_admin_password
  docker_username            = var.docker_username
  docker_password            = var.docker_password
  docker_email               = var.docker_email

  depends_on = [module.eks]
}

module "argo_cd" {
  source = "./modules/argo_cd"

  cluster_endpoint           = module.eks.cluster_endpoint
  cluster_ca_certificate     = module.eks.cluster_ca_certificate
  cluster_token              = data.aws_eks_cluster_auth.cluster.token
  namespace                  = var.argocd_namespace
  argocd_admin_password      = var.argocd_admin_password
  django_app_repo            = var.django_app_repo
  django_app_path            = var.django_app_path
  django_app_branch          = var.django_app_branch

  depends_on = [module.eks, module.jenkins]
}

output "s3_bucket_id" {
  description = "S3 bucket ID for Terraform state"
  value       = module.s3_backend.s3_bucket_id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = module.jenkins.jenkins_namespace
}

output "jenkins_service_name" {
  description = "Jenkins service name"
  value       = module.jenkins.jenkins_service_name
}

output "jenkins_admin_user" {
  description = "Jenkins admin username"
  value       = module.jenkins.jenkins_admin_user
}

output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = module.argo_cd.argo_cd_namespace
}

output "argocd_release_name" {
  description = "Argo CD release name"
  value       = module.argo_cd.argo_cd_release_name
}

output "argocd_admin_user" {
  description = "Argo CD admin username"
  value       = module.argo_cd.argo_cd_admin_user
}

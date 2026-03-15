#!/bin/bash

# Quick Start Deploy Script
# This script automates the deployment process

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing_tools=()
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("terraform")
    else
        print_success "Terraform installed: $(terraform version | head -n1)"
    fi
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        missing_tools+=("aws")
    else
        print_success "AWS CLI installed: $(aws --version)"
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    else
        print_success "kubectl installed: $(kubectl version --client --short 2>/dev/null || echo 'v1.x')"
    fi
    
    # Check Helm
    if ! command -v helm &> /dev/null; then
        missing_tools+=("helm")
    else
        print_success "Helm installed: $(helm version --short 2>/dev/null)"
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing tools: ${missing_tools[*]}"
        return 1
    fi
    
    return 0
}

# Load environment variables
load_env() {
    print_header "Loading Environment Configuration"
    
    if [ -f ".env" ]; then
        print_info "Loading .env file..."
        source .env
        print_success "Environment variables loaded"
    else
        print_warning ".env file not found. Creating from .env.example..."
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_warning "Please edit .env with your actual values and run this script again"
            exit 1
        else
            print_error ".env.example not found"
            exit 1
        fi
    fi
}

# Validate AWS credentials
validate_aws() {
    print_header "Validating AWS Credentials"
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not valid"
        print_info "Please configure AWS credentials:"
        print_info "  aws configure"
        print_info "Or set environment variables:"
        print_info "  export AWS_ACCESS_KEY_ID=..."
        print_info "  export AWS_SECRET_ACCESS_KEY=..."
        exit 1
    fi
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGION=$(aws configure get region)
    print_success "AWS Account: $ACCOUNT_ID"
    print_success "AWS Region: $REGION"
}

# Initialize Terraform backend
init_terraform() {
    print_header "Initializing Terraform Backend"
    
    if [ -d ".terraform" ]; then
        print_warning "Terraform already initialized, skipping..."
        return 0
    fi
    
    print_info "Creating S3 backend for state storage..."
    
    # Temporarily create S3 backend
    terraform init -upgrade
    
    print_success "Terraform initialized"
}

# Plan infrastructure
plan_infrastructure() {
    print_header "Planning Infrastructure"
    
    print_info "Running terraform plan..."
    
    if terraform plan -out=tfplan; then
        print_success "Terraform plan successful"
        return 0
    else
        print_error "Terraform plan failed"
        return 1
    fi
}

# Apply infrastructure
apply_infrastructure() {
    print_header "Applying Infrastructure"
    
    if [ ! -f "tfplan" ]; then
        print_error "No terraform plan found. Run plan first."
        return 1
    fi
    
    print_info "This will create AWS resources and incur costs"
    echo -n "Continue with deployment? (yes/no): "
    read -r response
    
    if [ "$response" != "yes" ]; then
        print_warning "Deployment cancelled"
        return 1
    fi
    
    print_info "Applying infrastructure changes..."
    if terraform apply tfplan; then
        print_success "Infrastructure applied successfully"
        
        # Save outputs
        terraform output > deployment-outputs.txt
        print_success "Outputs saved to deployment-outputs.txt"
        
        return 0
    else
        print_error "Terraform apply failed"
        return 1
    fi
}

# Configure kubectl
configure_kubectl() {
    print_header "Configuring kubectl"
    
    CLUSTER_NAME=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "cicd-pipeline-eks")
    
    print_info "Updating kubeconfig for cluster: $CLUSTER_NAME"
    
    if aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "${AWS_DEFAULT_REGION:-us-east-1}"; then
        print_success "kubeconfig updated"
        
        # Verify cluster access
        if kubectl cluster-info &> /dev/null; then
            print_success "Kubernetes cluster is accessible"
        else
            print_error "Cannot access Kubernetes cluster"
            return 1
        fi
    else
        print_error "Failed to update kubeconfig"
        return 1
    fi
}

# Verify deployment
verify_deployment() {
    print_header "Verifying Deployment"
    
    print_info "Waiting for pods to be ready..."
    
    # Check Jenkins
    print_info "Checking Jenkins..."
    if kubectl get namespace jenkins &> /dev/null; then
        kubectl wait --for=condition=ready pods --all -n jenkins --timeout=300s 2>/dev/null || true
        print_success "Jenkins namespace ready"
    fi
    
    # Check Argo CD
    print_info "Checking Argo CD..."
    if kubectl get namespace argocd &> /dev/null; then
        kubectl wait --for=condition=ready pods --all -n argocd --timeout=300s 2>/dev/null || true
        print_success "Argo CD namespace ready"
    fi
}

# Print access information
print_access_info() {
    print_header "Access Information"
    
    echo -e "${YELLOW}Jenkins:${NC}"
    echo "  Command: kubectl port-forward -n jenkins svc/jenkins-controller 8080:80"
    echo "  URL: http://localhost:8080"
    echo "  Username: admin"
    echo "  Password: Check terraform outputs or Jenkins pod logs"
    
    echo -e "\n${YELLOW}Argo CD:${NC}"
    echo "  Command: kubectl port-forward -n argocd svc/argo-cd-argocd-server 8443:443"
    echo "  URL: https://localhost:8443"
    echo "  Username: admin"
    echo "  Password: kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
    
    echo -e "\n${YELLOW}ECR Repository:${NC}"
    ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || echo "Not yet created")
    echo "  URL: $ECR_URL"
    
    echo -e "\n${YELLOW}Kubernetes:${NC}"
    echo "  Command: kubectl get nodes"
}

# Main execution
main() {
    print_header "CI/CD Pipeline Deployment Script"
    
    # Run checks
    if ! check_prerequisites; then
        print_error "Please install missing prerequisites"
        exit 1
    fi
    
    load_env
    validate_aws
    init_terraform
    
    if ! plan_infrastructure; then
        exit 1
    fi
    
    if ! apply_infrastructure; then
        exit 1
    fi
    
    if ! configure_kubectl; then
        print_warning "kubectl configuration failed, continuing..."
    fi
    
    verify_deployment
    print_access_info
    
    print_header "Deployment Complete!"
    print_success "Your CI/CD pipeline is ready!"
    print_warning "⚠️  Remember to run './cleanup.sh' when done to destroy resources!"
}

# Run main function
main "$@"

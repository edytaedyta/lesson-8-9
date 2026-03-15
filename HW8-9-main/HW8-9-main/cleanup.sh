#!/bin/bash

# Cleanup Script
# Destroys all infrastructure created by Terraform

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Main cleanup function
cleanup() {
    print_header "CI/CD Pipeline Cleanup"
    
    print_warning "⚠️  This will DESTROY all AWS resources created during deployment!"
    print_warning "This action CANNOT be undone!"
    echo ""
    echo "Resources that will be deleted:"
    echo "  • EKS Cluster"
    echo "  • EC2 Instances (nodes)"
    echo "  • VPC and subnets"
    echo "  • Load Balancers"
    echo "  • Security Groups"
    echo "  • ECR Repository"
    echo "  • IAM Roles and Policies"
    echo "  • RDS Instances (if any)"
    echo ""
    
    echo -n "Type 'destroy-all' to confirm cleanup: "
    read -r confirmation
    
    if [ "$confirmation" != "destroy-all" ]; then
        print_warning "Cleanup cancelled"
        exit 0
    fi
    
    echo ""
    print_info "Starting resource cleanup..."
    echo ""
    
    # Destroy with auto-approval
    if terraform destroy -auto-approve; then
        print_success "Infrastructure destroyed successfully"
    else
        print_error "Some resources may not have been destroyed"
        print_info "Try running 'terraform destroy' manually for more details"
    fi
    
    # Clean up local terraform files
    print_info "Cleaning up Terraform files..."
    
    if [ -d ".terraform" ]; then
        rm -rf .terraform
        print_success "Terraform working directory removed"
    fi
    
    if [ -f ".terraform.lock.hcl" ]; then
        rm -f .terraform.lock.hcl
        print_success "Terraform lock file removed"
    fi
    
    # Backup state file
    if [ -f "terraform.tfstate" ]; then
        BACKUP_FILE="terraform.tfstate.backup.$(date +%s)"
        cp terraform.tfstate "$BACKUP_FILE"
        print_success "State file backed up to: $BACKUP_FILE"
        rm -f terraform.tfstate
        print_success "State file removed"
    fi
    
    if [ -f "terraform.tfstate.backup" ]; then
        rm -f terraform.tfstate.backup
        print_success "Old backup removed"
    fi
    
    # Remove deployment outputs
    if [ -f "deployment-outputs.txt" ]; then
        rm -f deployment-outputs.txt
        print_success "Deployment outputs removed"
    fi
    
    if [ -f "tfplan" ]; then
        rm -f tfplan
        print_success "Terraform plan removed"
    fi
    
    print_header "Cleanup Complete"
    print_success "All resources have been destroyed!"
    print_info "Make sure to verify in AWS Console that resources are gone"
    
    echo -e "\nVerification steps:"
    echo "  1. Check EC2 Dashboard - no instances should be running"
    echo "  2. Check EKS Console - cluster should be deleted"
    echo "  3. Check VPC Console - VPC should be deleted"
    echo "  4. Check ECR Console - repository should be empty/deleted"
    echo "  5. Check S3 - verify state bucket is cleaned"
    echo "  6. Check CloudWatch - log groups can be cleaned manually if desired"
}

# Additional cleanup options
post_cleanup_info() {
    print_header "Additional Cleanup (Optional)"
    
    echo -e "${YELLOW}S3 Backend Cleanup:${NC}"
    echo "If you want to remove the S3 bucket and DynamoDB table used for state:"
    echo ""
    echo "  1. List S3 contents:"
    echo "     aws s3 ls s3://cicd-terraform-state-*/"
    echo ""
    echo "  2. Delete S3 bucket contents:"
    echo "     aws s3 rm s3://cicd-terraform-state-*/ --recursive"
    echo ""
    echo "  3. Delete S3 bucket:"
    echo "     aws s3api delete-bucket --bucket cicd-terraform-state-*"
    echo ""
    echo "  4. Delete DynamoDB table:"
    echo "     aws dynamodb delete-table --table-name cicd-terraform-locks"
    echo ""
    
    echo -e "${YELLOW}CloudWatch Logs Cleanup:${NC}"
    echo "Remove EKS cluster log groups:"
    echo "  aws logs describe-log-groups --query 'logGroups[].logGroupName' --output text | grep /aws/eks | xargs -I {} aws logs delete-log-group --log-group-name {}"
    echo ""
    
    echo -e "${YELLOW}IAM Cleanup:${NC}"
    echo "OIDC Provider cleanup (if created):"
    echo "  aws iam delete-open-id-connect-provider --open-id-connect-provider-arn <arn>"
}

# Run cleanup
cleanup
post_cleanup_info

print_warning "⚠️  Your AWS account is now cleaned up from CI/CD resources"
print_success "Thank you for using this deployment script!"

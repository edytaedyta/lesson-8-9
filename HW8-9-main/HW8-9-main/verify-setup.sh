#!/bin/bash

# Deployment Verification Script
# Run this script to verify the entire CI/CD pipeline is working

set -e

echo "🔍 Verifying CI/CD Pipeline Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Kubernetes access
echo -e "\n${YELLOW}[1] Checking Kubernetes cluster access...${NC}"
if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Kubernetes cluster is accessible"
else
    echo -e "${RED}✗${NC} Cannot access Kubernetes cluster"
    exit 1
fi

# Check EKS nodes
echo -e "\n${YELLOW}[2] Checking EKS nodes...${NC}"
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [ $NODE_COUNT -ge 1 ]; then
    echo -e "${GREEN}✓${NC} Found $NODE_COUNT node(s)"
    kubectl get nodes
else
    echo -e "${RED}✗${NC} No nodes found in cluster"
    exit 1
fi

# Check Jenkins namespace
echo -e "\n${YELLOW}[3] Checking Jenkins installation...${NC}"
if kubectl get ns jenkins &> /dev/null; then
    echo -e "${GREEN}✓${NC} Jenkins namespace exists"
    
    JENKINS_PODS=$(kubectl get pods -n jenkins --no-headers | grep -i jenkins | wc -l)
    if [ $JENKINS_PODS -ge 1 ]; then
        echo -e "${GREEN}✓${NC} Found $JENKINS_PODS Jenkins pod(s)"
        kubectl get pods -n jenkins
    else
        echo -e "${YELLOW}⚠${NC} No Jenkins pods running"
    fi
else
    echo -e "${RED}✗${NC} Jenkins namespace not found"
fi

# Check Argo CD namespace
echo -e "\n${YELLOW}[4] Checking Argo CD installation...${NC}"
if kubectl get ns argocd &> /dev/null; then
    echo -e "${GREEN}✓${NC} Argo CD namespace exists"
    
    ARGOCD_PODS=$(kubectl get pods -n argocd --no-headers | wc -l)
    if [ $ARGOCD_PODS -ge 1 ]; then
        echo -e "${GREEN}✓${NC} Found $ARGOCD_PODS Argo CD pod(s)"
        kubectl get pods -n argocd
    else
        echo -e "${YELLOW}⚠${NC} No Argo CD pods running"
    fi
else
    echo -e "${RED}✗${NC} Argo CD namespace not found"
fi

# Check ECR repository
echo -e "\n${YELLOW}[5] Checking ECR repository...${NC}"
if aws ecr describe-repositories --repository-names django-app &> /dev/null; then
    ECR_URL=$(aws ecr describe-repositories --repository-names django-app --query 'repositories[0].repositoryUri' --output text)
    echo -e "${GREEN}✓${NC} ECR repository found: $ECR_URL"
else
    echo -e "${YELLOW}⚠${NC} ECR repository not found"
fi

# Check Terraform state
echo -e "\n${YELLOW}[6] Checking Terraform state...${NC}"
if [ -f "terraform.tfstate" ] || [ -f ".terraform/terraform.tfstate" ]; then
    echo -e "${GREEN}✓${NC} Terraform state file found"
else
    echo -e "${YELLOW}⚠${NC} Terraform state file not found locally"
fi

# Summary
echo -e "\n${GREEN}✓ Basic verification complete!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Access Jenkins: kubectl port-forward -n jenkins svc/jenkins-controller 8080:80"
echo "2. Access Argo CD: kubectl port-forward -n argocd svc/argo-cd-argocd-server 8443:443"
echo "3. Create Jenkins pipeline job pointing to your django-app repository"
echo "4. Configure Argo CD to monitor the django-app repository"
echo "5. Push code to trigger the pipeline"

echo -e "\n${YELLOW}⚠️  Don't forget to run 'terraform destroy' when done!${NC}"

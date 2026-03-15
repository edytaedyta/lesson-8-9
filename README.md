# lesson-8-9

Automatyzacja CI/CD: Jenkins, Terraform, ECR, Helm oraz Argo CD
Kompletny, gotowy do wdrożenia produkcyjnego stos technologiczny DevOps, służący do pełnej automatyzacji cyklu życia aplikacji Django na platformie Kubernetes.

Niniejsze repozytorium prezentuje zaawansowany potok CI/CD, który:

Buduje obrazy kontenerów aplikacji Django przy użyciu narzędzia Kaniko (bez uprawnień roota).

Przesyła artefakty do repozytorium Amazon ECR (Elastic Container Registry).

Aktualizuje konfigurację Helm w systemie kontroli wersji Git, podbijając tagi obrazów.

Synchronizuje stan klastra za pomocą Argo CD, bazując na podejściu GitOps.

Architektura Systemu
Plaintext
┌─────────────────────────────────────────────────────────────┐
│                   Przepływ Procesu CI/CD                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Programista wysyła kod (Push) do Git                    │
│     ↓                                                       │
│  2. Jenkins wykrywa nową zmianę                             │
│     ↓                                                       │
│  3. Budowa obrazu i wypchnięcie do ECR                      │
│     ↓                                                       │
│  4. Modyfikacja manifestów Helm w Git                       │
│     ↓                                                       │
│  5. Argo CD automatycznie zauważa zmianę w Git              │
│     ↓                                                       │
│  6. Synchronizacja i wdrożenie na Kubernetes                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
Struktura Katalogów
Plaintext
Project/
├── main.tf                          # Główny plik Terraform
├── modules.tf                       # Deklaracje modułów
├── variables.tf                     # Definicje zmiennych wejściowych
├── outputs.tf                       # Parametry wyjściowe
├── backend.tf                       # Konfiguracja stanu (State)
├── terraform.tfvars                 # Wartości zmiennych
├── Jenkinsfile                      # Definicja potoku Jenkins
│
├── modules/
│   ├── s3-backend/                  # Zarządzanie stanem (S3 + DynamoDB)
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/                         # Sieć (VPC, podsieci, bramy)
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ecr/                         # Rejestr obrazów ECR
│   │   ├── ecr.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── eks/                         # Zarządzany klaster EKS
│   │   ├── eks.tf
│   │   ├── aws_ebs_csi_driver.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── jenkins/                     # Instalacja Jenkinsa (Helm)
│   │   ├── providers.tf
│   │   ├── jenkins.tf
│   │   ├── variables.tf
│   │   ├── values.yaml
│   │   └── outputs.tf
│   │
│   └── argo_cd/                     # Instalacja Argo CD (Helm)
│       ├── providers.tf
│       ├── jenkins.tf
│       ├── variables.tf
│       ├── values.yaml
│       ├── outputs.tf
│       └── charts/
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
│
└── charts/
    └── django-app/                  # Manifesty aplikacji Django
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── hpa.yaml
            ├── configmap.yaml
            ├── _serviceaccount.yaml
            └── _helpers.tpl
Wymagania Wstępne
Zanim zaczniesz, przygotuj następujące narzędzia:

Terraform (wersja >= 1.0)

AWS CLI ze skonfigurowanym dostępem (Access Keys)

kubectl (wersja >= 1.28)

Helm (wersja >= 3.10)

Git

Konto AWS z uprawnieniami do zarządzania infrastrukturą

Uprawnienia IAM
Twoje konto AWS musi posiadać uprawnienia do:

EC2 (VPC, Subnets, SG, NAT)

EKS (Cluster, Node Groups)

ECR (Zarządzanie repozytoriami)

S3 i DynamoDB (Obsługa stanu Terraform)

IAM (Tworzenie ról i polityk)

Procedura Instalacji
Krok 1: Konfiguracja Lokalna
Pobierz repozytorium i ustaw zmienne środowiskowe:

Bash
git clone https://github.com/twoj-uzytkownik/lesson-8-9.git
cd lesson-8-9

# Tworzenie pliku .env dla bezpieczeństwa
cat > .env << 'EOF'
export TF_VAR_jenkins_admin_password="twoje-haslo"
export TF_VAR_docker_username="uzytkownik-docker"
export TF_VAR_docker_password="token-docker"
export TF_VAR_docker_email="email@example.com"
export TF_VAR_argocd_admin_password="twoje-haslo-argo"
export TF_VAR_django_app_repo="https://github.com/uzytkownik/django-app.git"
EOF

source .env
Krok 2: Inicjalizacja Backend-u S3
Przy pierwszym uruchomieniu musimy utworzyć zasoby dla stanu zdalnego:

Bash
# Użyj lokalnego stanu do utworzenia S3 i DynamoDB
cat > backend-init.tf << 'EOF'
terraform {
  backend "local" {
    path = "terraform.tfstate.local"
  }
}
EOF

terraform init
terraform apply -target=module.s3_backend

# Pobierz dane o nowo utworzonych zasobach
STATE_BUCKET=$(terraform output -raw s3_bucket_id)
STATE_TABLE=$(terraform output -raw dynamodb_table_name)

rm backend-init.tf
Krok 3: Migracja Stanu do Chmury
Bash
terraform init \
  -backend-config="bucket=${STATE_BUCKET}" \
  -backend-config="dynamodb_table=${STATE_TABLE}"
# Wybierz "yes", aby przenieść dane do S3.
Krok 4: Wdrożenie Infrastruktury
Bash
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
Zasoby, które zostaną utworzone:

Sieć VPC (podsieci publiczne/prywatne).

Klaster EKS z grupami węzłów.

Rejestr ECR.

Instancje Jenkinsa oraz Argo CD wewnątrz klastra.

Zarządzanie i Testowanie
Dostęp do Klastra
Bash
aws eks update-kubeconfig --name cicd-pipeline-eks --region us-east-1
kubectl get nodes
Konfiguracja Jenkinsa
Logowanie: Wykonaj port-forwarding:
kubectl port-forward -n jenkins svc/jenkins-controller 8080:80

Hasło Admina:
kubectl get secret -n jenkins jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d

Poświadczenia: Dodaj SSH Key dla GitHub (github-ssh-key) oraz AWS Credentials dla ECR (ecr-registry-url).

Pipeline: Stwórz nowy "Pipeline" wskazując na swój adres repozytorium i plik Jenkinsfile.

Monitorowanie Argo CD
Dostęp: kubectl port-forward -n argocd svc/argo-cd-argocd-server 8443:443

Hasło: kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

Weryfikacja: Sprawdź status aplikacji komendą argocd app get django-app.

Bezpieczeństwo i Koszty
Dobre Praktyki
Zmienne: Nigdy nie przesyłaj .env ani .tfvars do Git.

RBAC: Używaj ról o najniższych uprawnieniach dla Jenkinsa i Argo CD.

Sieć: Węzły robocze EKS znajdują się w podsieciach prywatnych.

Usuwanie Zasobów
Aby uniknąć niepotrzebnych kosztów, po zakończeniu testów usuń infrastrukturę:

Bash
# 1. Usuń zasoby K8s
kubectl delete all -n jenkins
kubectl delete all -n argocd

# 2. Zniszcz infrastrukturę AWS
terraform destroy

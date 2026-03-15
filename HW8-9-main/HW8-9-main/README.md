Markdown# 🚀 Advanced CI/CD Pipeline: Django on Kubernetes

![Terraform](https://img.shields.io/badge/Terraform-1.0+-7B42BC?style=for-the-badge&logo=terraform)
![Jenkins](https://img.shields.io/badge/Jenkins-2.0+-D24939?style=for-the-badge&logo=jenkins)
![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-FF7F00?style=for-the-badge&logo=argo-cd)
![AWS](https://img.shields.io/badge/AWS-Cloud-232F3E?style=for-the-badge&logo=amazon-aws)

Kompleksowa, produkcyjna infrastruktura CI/CD wykorzystująca nowoczesne narzędzia DevOps do pełnej automatyzacji wdrażania aplikacji Django w środowisku Kubernetes (EKS).

## 🎯 Cel projektu
Ten projekt implementuje potok (pipeline), który realizuje podejście **GitOps** i **Infrastructure as Code**:
* **Budowa obrazów**: Automatyczne tworzenie obrazów Docker przez Kaniko.
* **Rejestr ECR**: Przechowywanie artefaktów w Amazon Elastic Container Registry.
* **Zarządzanie konfiguracją**: Automatyczna aktualizacja tagów w chartach Helm.
* **Ciągłe wdrażanie**: Synchronizacja stanu klastra przez Argo CD po wykryciu zmian w Git.

---

## 🏗 Architektura systemu

```text
┌─────────────────────────────────────────────────────────────┐
│                   PRZEPŁYW PROCESU CI/CD                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Deweloper wykonuje "git push"                           │
│     ↓                                                       │
│  2. Jenkins automatycznie startuje proces                   │
│     ↓                                                       │
│  3. Budowa obrazu Docker i wysyłka do AWS ECR               │
│     ↓                                                       │
│  4. Aktualizacja wersji obrazu w repozytorium Helm          │
│     ↓                                                       │
│  5. Argo CD wykrywa niespójność (Out of Sync)               │
│     ↓                                                       │
│  6. Synchronizacja i aktualizacja Deploymentu w K8s          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
📂 Struktura projektuKatalog / PlikOpismain.tfGłówna konfiguracja Terraformmodules/vpc/Izolowana sieć (Public/Private Subnets)modules/eks/Klaster Kubernetes i Node Groupymodules/jenkins/Instalacja Jenkinsa przez Helmmodules/argo_cd/Instalacja i konfiguracja Argo CDcharts/django-app/Manifesty Kubernetes dla aplikacjiJenkinsfileDefinicja etapów budowania i testowania🛠 Wymagania wstępneNarzędzia CLI: terraform, aws-cli, kubectl, helm.Konto Cloud: AWS z uprawnieniami Administratora (IAM).Repozytorium: Dostęp SSH do GitHuba dla Jenkinsa.🚀 Szybki start (Deployment)1. Przygotowanie środowiskaSkonfiguruj zmienne lokalne w pliku .env (plik ten jest ignorowany przez .gitignore):Bashcat > .env << 'EOF'
export TF_VAR_jenkins_admin_password="twoje-mocne-haslo"
export TF_VAR_argocd_admin_password="inne-mocne-haslo"
export TF_VAR_django_app_repo="[https://github.com/uzytkownik/django-app.git](https://github.com/uzytkownik/django-app.git)"
EOF

source .env
2. Inicjalizacja Backend-u S3 (State Management)Aby bezpiecznie przechowywać stan Terraform, utwórz najpierw zasoby S3:Bashterraform init
terraform apply -target=module.s3_backend
3. Uruchomienie pełnej infrastrukturyPo skonfigurowaniu backendu, wykonaj pełne wdrożenie:Bashterraform plan -out=tfplan
terraform apply tfplan
🛡 Bezpieczeństwo i Koszty[!IMPORTANT]Pamiętaj, że uruchomienie klastra EKS i NAT Gateway na AWS generuje koszty.Sekrety: Wszystkie hasła są przekazywane jako zmienne Terraform i nie są zapisywane w kodzie.Izolacja: Jenkins i aplikacja działają wewnątrz prywatnych podsieci.Cleanup: Po zakończeniu testów, wykonaj terraform destroy, aby usunąć wszystkie zasoby i uniknąć opłat.📊 Wyjścia (Outputs)Po poprawnym wykonaniu komendy apply, otrzymasz następujące dane:eks_cluster_endpoint: Adres API klastra.ecr_repository_url: Adres Twojego prywatnego rejestru obrazów.jenkins_service_name: Nazwa usługi Jenkins w K8s.
# 🚀 FastAPI Deployment on AWS (Docker + ECR + EC2 + Terraform + GitHub Actions)

This project demonstrates how to deploy a FastAPI application to AWS using:

- **Docker** for containerization
- **Amazon ECR** as the image registry
- **EC2** to run the application
- **Terraform** for infrastructure-as-code
- **S3 + DynamoDB** for Terraform remote backend
- **GitHub Actions** for full CI/CD automation

Push code → Build Docker Image → Push to ECR → Terraform deploys → EC2 runs FastAPI.

---

## ⚡️ FastAPI Local Setup

Install dependencies and run FastAPI locally:

```bash
pip install fastapi uvicorn
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Open:

```
http://127.0.0.1:8000
```

---

## 🐳 Docker Build (Manual Test)

Build and run the Docker image locally:

```bash
docker build -t fastapi-ec2-demo:latest .
docker run -p 80:80 fastapi-ec2-demo:latest
```

Visit:

```
http://localhost/
```

---

## 🧱 Terraform Setup (Infrastructure as Code)

All Terraform files live inside:

```
infra/
```

### 1️⃣ Initialize Terraform Without Backend (Bootstrap Mode)

If S3 + DynamoDB do **not** exist:

Comment out backend config in `backend.tf`, then run:

```bash
cd infra
terraform init
terraform apply
```

This automatically creates:

- **S3 bucket** → Terraform state
- **DynamoDB table** → state locking

---

### 2️⃣ Enable Terraform Remote Backend (S3 + DynamoDB)

Once the resources exist, enable backend:

```bash
terraform init -migrate-state
```

Terraform now reads/writes state to S3.

> If S3/DynamoDB already exist → just run `terraform init`.

---

## 🤖 GitHub Actions — Fully Automated CI/CD Pipeline

Pipeline file:

```
.github/workflows/deploy.yml
```

### On every push to `main` or `master`, the pipeline will:

1. Checkout code
2. Configure AWS credentials (from GitHub Secrets)
3. Login to Amazon ECR
4. Build Docker image
5. Push image to ECR
6. Run Terraform:

```bash
terraform init
terraform apply -auto-approve
```

### Terraform then provisions:

- Amazon ECR Repository
- EC2 Instance (with Public IP)
- IAM Role + Instance Profile
- Security Group (port 80 open)

### EC2 user-data performs:

- Install Docker
- Authenticate to ECR
- Pull your latest image
- Run the FastAPI container on **port 80**

Your API becomes available immediately.

---

## 📘 How to Use This Repository

### 1. Clone or fork the repo

### 2. Update these variables in `infra/variables.tf`:

- `aws_region`
- `project_name`
- `ami_id` (Amazon Linux AMI)

### 3. Add GitHub repo secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 4. Push to `main` or `master`

→ GitHub Actions deploys infrastructure automatically.

### 5. After deployment:

Go to **AWS EC2 Console**, copy the instance’s **Public IPv4** address, open:

```
http://<ec2-public-ip>/
```

You should see the FastAPI JSON response.

---

## 🧨 Teardown (Clean-Up)

To destroy all AWS resources provisioned by Terraform:

```bash
cd infra
terraform destroy
```

This removes:

- EC2
- ECR
- IAM resources
- Security Group

> S3 + DynamoDB must be deleted manually if no longer needed.

---

## 📝 Recommended Improvements

- Add HTTPS via **ALB + ACM**
- Enable GitHub Actions **OIDC authentication** (no secrets needed)
- Add monitoring via:
  - CloudWatch
  - Datadog
  - Prometheus
- Use commit SHAs for Docker image tagging instead of `latest`

---

## 📄 License

This project is for **educational and demonstration** purposes.  
Feel free to reuse or adapt it.

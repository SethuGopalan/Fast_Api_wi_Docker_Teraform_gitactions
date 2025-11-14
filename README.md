## 🚀 Prerequisites

### **Local Machine**

- 🐍 **Python 3.11+** (optional, only if running FastAPI locally)
- 🐳 **Docker**
- 🧱 **Terraform ≥ 1.6**
- ☁️ **AWS CLI** configured with an IAM user/role that has:
  - ECR
  - EC2
  - IAM
  - S3
  - DynamoDB
  - CloudWatch  
    permissions

### **GitHub**

Set these **repository secrets**:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

> (You can switch to GitHub OIDC later — this setup uses classic access keys for simplicity.)

---

## ⚡ FastAPI App (Local Test Optional)

From the project root:

```bash
pip install fastapi uvicorn
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

Open in browser:
http://127.0.0.1:8000

Docker Build (Manual Test)

To build and run the Docker image locally:
docker build -t fastapi-ec2-demo:latest .
docker run -p 80:80 fastapi-ec2-demo:latest
Terraform Setup

All Terraform files live inside the infra/ directory.

1. Initialize Once Without Backend (Optional Bootstrap)

If the S3 bucket and DynamoDB lock table do not exist yet:

Comment out the backend "s3" block in backend.tf

Run:

cd infra
terraform init
terraform apply
This creates:

S3 bucket for Terraform state

DynamoDB table for state locking

2. Re-enable the Backend

After resources are created, run:

terraform init -migrate-state


Terraform now uses S3 + DynamoDB for remote state.

If the bucket & table already exist, skip bootstrap and run terraform init normally.
GitHub Actions – CI/CD Flow

Workflow file:

.github/workflows/deploy.yml


On push to main or master, the pipeline will:

Checkout repository

Configure AWS credentials (from GitHub secrets)

Login to ECR

Build Docker image

Tag & push image to ECR

Run Terraform:

terraform init (S3 backend + DynamoDB lock)

terraform apply -auto-approve

Terraform will create/update:

ECR repository

EC2 instance (with public IP)

Security Group (port 80 open)

IAM role + Instance Profile for EC2

EC2 user data script will:

Install Docker

Authenticate to ECR

Pull the latest Docker image

Run the container:
How to Use This Repository

Fork or clone this repository.

Update infra/variables.tf:

aws_region

project_name

ami_id (valid Amazon Linux AMI)

Commit and push changes.

Ensure GitHub Actions secrets are configured:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

Push to main or master → pipeline triggers automatically.

After deployment:

Go to AWS EC2 Console

Copy the public IPv4 address

Open in browser:
http://<ec2-public-ip>/
You should see JSON from the FastAPI root endpoint.

🧨 Teardown

To destroy all Terraform-managed infrastructure:

cd infra
terraform destroy


This removes:

EC2

ECR

IAM

Security Group

The S3 bucket & DynamoDB table for Terraform state remain unless deleted manually.

📝 Notes / To-Do

Add HTTPS using ALB + ACM

Switch GitHub Actions to AWS OIDC

Add monitoring (CloudWatch, Datadog, Prometheus)

Tag Docker images using commit SHA instead of latest

📄 License

This project is for educational and demonstration purposes.
Feel free to reuse or modify it for your own deployments.

---

If you want, I can **combine all your README sections into one final polished document**, or even add:

✅ Architecture diagram (ASCII or image)
✅ Troubleshooting section (Terraform, EC2, ECR errors)
✅ Deployment flow diagram

Just tell me!
astAPI Deployment on AWS (Docker + ECR + EC2 + Terraform + GitHub Actions)

⚡ FastAPI Local Setup

Install dependencies and run FastAPI locally:

    pip install fastapi uvicorn
    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

Open: http://127.0.0.1:8000

🐳 Docker Build (Manual Test)

    docker build -t fastapi-ec2-demo:latest .
    docker run -p 80:80 fastapi-ec2-demo:latest

Open: http://localhost/

🧱 Terraform Setup

All Terraform files live inside infra/.

1) Initialize Without Backend

If S3 + DynamoDB do not exist:

    cd infra
    terraform init
    terraform apply

2) Enable Backend

    terraform init -migrate-state

🤖 GitHub Actions CI/CD

Pipeline will: - Checkout repo
- Configure AWS creds
- Login to ECR
- Build & push Docker image
- Terraform init + apply

📘 How to Use

1.  Fork repo
2.  Update infra/variables.tf
3.  Add GitHub secrets
4.  Push to main/master

After deployment open: http:///

🧨 Teardown

    cd infra
    terraform destroy

📝 Notes

-   Add HTTPS (ALB + ACM)
-   Switch to OIDC
-   Add monitoring
```

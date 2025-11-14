Developer push code to main or master.

GitHub Actions:

Builds Docker image for FastAPI.

Logs in to ECR.

Pushes image to fastapi-ec2-demo-repo:latest.

Runs terraform init with S3 backend + DynamoDB lock.

Runs terraform apply:

Ensures S3 bucket + DynamoDB table exist (first time).

Creates / updates ECR repo, EC2 instance, IAM, SG.

EC2 user data:

Installs Docker.

Logs into ECR.

Pulls latest image.

Runs container on port 80.

You test:
http://<ec2-public-ip>/ → returns JSON message from FastAPI.

# FastAPI Deployment on AWS (Docker + ECR + EC2 + Terraform + GitHub Actions)

This project is a small end-to-end setup to deploy a **FastAPI** application to **AWS EC2** using:

- **Docker** – containerize the FastAPI app
- **Amazon ECR** – store the Docker image
- **EC2** – run the container
- **Terraform** – provision AWS infrastructure
- **S3 + DynamoDB** – remote Terraform state + state locking
- **GitHub Actions** – build & deploy on every push

The goal is:

> Push code to GitHub → Docker image builds & pushes to ECR → Terraform applies → EC2 pulls image and runs FastAPI automatically.

---

## Architecture Overview

1. FastAPI app lives under `app/`.
2. Dockerfile builds an image that exposes FastAPI on port **80**.
3. AWS resources (ECR repo, EC2 instance, IAM, S3, DynamoDB, SG) are managed by Terraform in `infra/`.
4. Terraform state is stored in **S3** with a **DynamoDB** lock table.
5. A GitHub Actions workflow in `.github/workflows/deploy.yml`:
   - Builds & pushes the Docker image to ECR.
   - Runs `terraform init` and `terraform apply` to update infrastructure.
6. EC2 user data installs Docker, logs into ECR, pulls the latest image, and runs the container.

---

## Folder Structure

```text
fastapi-ec2-deploy/
│
├─ app/
│  └─ main.py              # FastAPI application
│
├─ Dockerfile              # Container build for the app
│
├─ infra/                  # Terraform configuration
│  ├─ provider.tf
│  ├─ backend.tf
│  ├─ s3_backend.tf
│  ├─ ecr_ec2.tf
│  └─ variables.tf
│
└─ .github/
   └─ workflows/
      └─ deploy.yml        # GitHub Actions CI/CD pipeline
Prerequisites
Local

Python 3.11+ (optional, only if you want to run locally)

Docker

Terraform ≥ 1.6

AWS CLI configured with an IAM user/role that has:

ECR, EC2, IAM, S3, DynamoDB, CloudWatch permissions

GitHub

In your GitHub repository settings, define these secrets:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

(You can switch to OIDC later; this setup uses classic access keys for simplicity.)

FastAPI App (Local Test Optional)

From the project root:

pip install fastapi uvicorn
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

Docker Build (Manual)

To test the Docker image locally:

docker build -t fastapi-ec2-demo:latest .
docker run -p 80:80 fastapi-ec2-demo:latest

Terraform Setup

All Terraform files live in infra/.

1. Initialize once without backend (optional bootstrap)

If the S3 bucket and DynamoDB table do not exist yet, you can:

Comment out the backend "s3" block in backend.tf.

Run:

cd infra
terraform init
terraform apply


This creates:

S3 bucket for tfstate

DynamoDB table for locking

Then uncomment the backend block, run:

terraform init -migrate-state


Now Terraform state uses S3 + DynamoDB.

If you already created the bucket & table manually, you can skip the bootstrap step and go directly to terraform init with backend enabled.

GitHub Actions – CI/CD Flow

The workflow file: .github/workflows/deploy.yml.

On push to main or master, it will:

Checkout repository.

Configure AWS credentials using repo secrets.

Login to ECR.

Build Docker image from Dockerfile.

Tag & push image to the ECR repository.

Run Terraform (terraform init with S3 backend and DynamoDB lock).

Apply Terraform (terraform apply -auto-approve).

Terraform will:

Ensure S3 bucket + DynamoDB lock table are present.

Create or update:

ECR repo

EC2 instance (with public IP)

Security group for port 80

IAM role + instance profile for EC2 to pull from ECR

The EC2 user data:

Installs Docker

Logs into ECR

Pulls :latest image

Runs the container with -p 80:80

How to Use This Repo

Fork or clone this repository.

Update values in infra/variables.tf:

aws_region

project_name

ami_id (use a valid Amazon Linux AMI for your region).

Commit and push.

Ensure GitHub secrets are configured.

Push to main / master → pipeline runs automatically.

After a successful run:

Go to AWS EC2 console, grab the public IPv4 address of the instance.

Open in browser:

http://<ec2-public-ip>/


You should see JSON from the FastAPI root endpoint.

Teardown

To destroy all infrastructure created by Terraform:

cd infra
terraform destroy


This will remove EC2, ECR, IAM resources, SG, etc.
You can keep or manually delete the S3 bucket and DynamoDB table, depending on whether you want to preserve state history.

Notes / To-Do

Add HTTPS using ALB + ACM (optional).

Switch from static access keys to AWS OIDC for GitHub Actions.

Add health check endpoint and monitoring (CloudWatch / Datadog / Prometheus).

Parameterize the Docker image tag (e.g., use commit SHA instead of latest).

License

This project is for personal learning and demo purposes.
Feel free to reuse and modify for your own deployments.

If you want, I can also add a small ASCII architecture diagram or a “troubleshooting” section in your style (Terraform init errors, S3 bucket name issues, AMI mistakes, etc.).


```

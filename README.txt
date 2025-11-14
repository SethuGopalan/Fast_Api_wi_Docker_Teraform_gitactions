FastAPI Deployment on AWS (Docker + ECR + EC2 + Terraform + GitHub Actions)

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

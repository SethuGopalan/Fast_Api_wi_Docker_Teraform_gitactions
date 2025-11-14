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

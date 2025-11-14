from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "FastAPI on EC2 via Docker + ECR + Terraform + GitHub Actions"}

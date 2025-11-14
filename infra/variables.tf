variable "ami_id" {
  type        = string
  description = "Amazon Linux 2 (or 2023) AMI ID for the region"
}

variable "fast_api" {
  type        = string
  description = "Repository name prefix for FastAPI ECR repo"
  default     = "fastapi"
}

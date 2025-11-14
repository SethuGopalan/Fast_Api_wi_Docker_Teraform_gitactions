# ECR repo for Docker image
resource "aws_ecr_repository" "fastapi_repo" {
  name = "${var.project_name}-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Security group for EC2 – open port 80
resource "aws_security_group" "fastapi_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP for FastAPI"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# IAM role for EC2 so it can pull from ECR
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 instance user data: pull + run container
resource "aws_instance" "fastapi_ec2" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  subnet_id                   = data.aws_subnet_ids.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.fastapi_sg.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user

              REGION="${var.aws_region}"
              REPOSITORY_URI="${aws_ecr_repository.fastapi_repo.repository_url}"
              IMAGE_TAG="latest"

              aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPOSITORY_URI

              docker pull ${aws_ecr_repository.fastapi_repo.repository_url}:$IMAGE_TAG
              docker run -d -p 80:80 ${aws_ecr_repository.fastapi_repo.repository_url}:$IMAGE_TAG
              EOF

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

variable "aws_region" {
  description = "Primary region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "middleware_ecr_image_uri" {
  description = "The ECR image URI for the middleware"
  type        = string
  default     = "905906650285.dkr.ecr.us-east-1.amazonaws.com/strand-middleware:latest"
}

variable "quanum_ecr_image_uri" {
  description = "The ECR image URI for the mock quanum-hub"
  type        = string
  default     = "905906650285.dkr.ecr.us-east-1.amazonaws.com/quanum-hub:latest"
}

variable "s3_bucket_arn" {
  description = "The S3 bucket run for logs and cloudtrail"
  type        = string
  default     = "arn:aws:s3:::qdm-tf-state"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.10"

  backend "s3" {
    bucket = "qdm-tf-state"                # Name of your S3 bucket
    key    = "terraform/terraform.tfstate" # Path/name of the state file
    region = "us-east-1"                   # Region of the bucket
  }
}

locals {
  name_prefix  = "quest-proxy"
  project_name = "qd-middleware"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = local.project_name
    }
  }
}

# --- Module: VPC Data ---
# Creates the vpc and subnets with gateways
module "vpc" {
  source = "./modules/vpc"

  name_prefix = local.name_prefix
}

# --- Module: KMS ---
# Creates the encryption key
module "kms" {
  source = "./modules/kms"

  name_prefix = local.name_prefix
}

# --- Module: Cognito ---
# Creates the User Pool and Client
module "cognito" {
  source = "./modules/cognito"

  name_prefix = local.name_prefix
  kms_key_arn = module.kms.kms_key_arn
}

# --- Module: DynamoDB ---
# Creates Dynamodb for reconciliation
module "dynamodb" {
  source = "./modules/dynamodb"

  name_prefix = local.name_prefix
  kms_key_arn = module.kms.kms_key_arn
}

# --- Module: API Gateway ---
# Creates the API, /ANY endpoint, authorizer, and ALB integration
module "api_gateway" {
  source = "./modules/api_gateway"

  aws_region            = var.aws_region
  name_prefix           = local.name_prefix
  cognito_user_pool_arn = module.cognito.cognito_pool_arn
  nlb_arn               = module.ecs_processor.nlb_arn
  nlb_dns_name          = module.ecs_processor.nlb_dns_name
  kms_key_arn           = module.kms.kms_key_arn
}

# --- Module: WAF ---
# Creates the WAF ACL with rule groups for Cognito and API Gateway
module "waf" {
  source = "./modules/waf"

  name_prefix           = local.name_prefix
  api_gateway_arn       = module.api_gateway.rest_api_arn
  cognito_user_pool_arn = module.cognito.cognito_pool_arn
  kms_key_arn           = module.kms.kms_key_arn
}

# --- Module: ECS Processor ---
# Creates the ECS Cluster, Task Def, Service, and Auto-Scaling
module "ecs_processor" {
  source = "./modules/ecs_processor"

  aws_region         = var.aws_region
  name_prefix        = local.name_prefix
  ecr_image_uri      = var.middleware_ecr_image_uri
  quest_server_url   = module.mock_quanum_hub.service_url
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  kms_key_arn        = module.kms.kms_key_arn
  dynamodb_table_arn = module.dynamodb.dynamodb_arn
}

# --- Module: Auditing ---
# Creates CloudTrail and the auth failure alarm
module "auditing" {
  source        = "./modules/auditing"
  kms_key_arn   = module.kms.kms_key_arn
  name_prefix   = local.name_prefix
  s3_bucket_arn = var.s3_bucket_arn
}

# --- Module: App Runner ---
# Creates Mock Quest server
module "mock_quanum_hub" {
  source           = "./modules/app_runner"
  name_prefix      = local.name_prefix
  server_ecr_image = var.quanum_ecr_image_uri
}
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

locals {
  cluster_outputs       = jsondecode(file("${path.module}/cluster_outputs.json"))
  vpc_id                = local.cluster_outputs.vpc_id.value
  private_subnet_ids    = local.cluster_outputs.private_subnets.value
}

terraform {
  backend "s3" {
    bucket         = "terraform-integration-state-bucket"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}
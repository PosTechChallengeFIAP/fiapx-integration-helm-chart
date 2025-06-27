provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

terraform {
  backend "s3" {
    bucket         = "fiapx-terraform-state-bucket"
    key            = "integration/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "fiapx-terraform-state-bucket"
    key    = "cluster/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  vpc_id                = data.terraform_remote_state.cluster.outputs.vpc_id
  private_subnet_ids    = data.terraform_remote_state.cluster.outputs.private_subnets
}
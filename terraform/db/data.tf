data "terraform_remote_state" "aurora_infra" {
  backend = "s3"
  config = {
    bucket = "fiapx-terraform-state-bucket"
    key    = "cluster/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  aurora_db_endpoint = "${data.terraform_remote_state.aurora_infra.outputs.aurora_db_endpoint}:3306"
}
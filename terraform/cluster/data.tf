data "aws_iam_role" "default" {
  name = "LabRole"
}

locals {
  lab_role_arn          = data.aws_iam_role.default.arn
}
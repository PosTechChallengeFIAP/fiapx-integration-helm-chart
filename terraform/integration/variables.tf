variable "user_management_nlb_dns" {
  type = string
}

variable "user_management_nlb_arn" {
  type = string
}

variable "video_processor_nlb_dns" {
  type = string
}

variable "video_processor_nlb_arn" {
  type = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # or your preferred region
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "aws_session_token" {
  description = "AWS Session Token"
  type        = string
}
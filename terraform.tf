# Configure Terraform.

terraform {
  required_version = "~> 0.13"

  # https://www.terraform.io/docs/backends/types/s3.html
  backend "s3" {
    bucket = "andys-terraform-backend"
    region = "us-east-1"
    key    = "hello-app-web/terraform.tfstate"
  }
}

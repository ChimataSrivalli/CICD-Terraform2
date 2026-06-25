terraform {
  backend "s3" {

    bucket = "srivalli-tf-backend"

    key = "dev/terraform.tfstate"

    region = "ap-south-1"
  }
}
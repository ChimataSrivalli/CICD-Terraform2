terraform {
  backend "s3" {

    bucket = "terraform-srivalli"

    key = "dev/terraform.tfstate"

    region = "ap-south-1"
  }
}
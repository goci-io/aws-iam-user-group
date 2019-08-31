terraform {
  required_version = ">= 0.12.1"
  backend "s3" {}
}

provider "aws" {
  version = "~> 2.25"
}

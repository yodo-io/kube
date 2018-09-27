terraform {
  version = "0.11.8"

  backend "s3" {
    bucket = "tfstate-468871832330"
    key    = "mykops/1"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.17"
}

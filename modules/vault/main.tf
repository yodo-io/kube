provider "local" {
  version = "~> 1.1"
}

provider "template" {
  version = "~> 1.0"
}

locals {
  bucket_name = "${var.project_name}-vault-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project = "${var.project_name}"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

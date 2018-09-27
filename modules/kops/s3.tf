resource "aws_s3_bucket" "kops_state" {
  bucket = "kops-state-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = "${local.tags}"
}

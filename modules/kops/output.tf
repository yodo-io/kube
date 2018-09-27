output "iam_secret_key" {
  value     = "${aws_iam_access_key.kops.secret}"
  sensitive = true
}

output "iam_access_key_id" {
  value = "${aws_iam_access_key.kops.id}"
}

output "state_store" {
  value = "s3://${aws_s3_bucket.kops_state.bucket}"
}

output "subdomain" {
  value = "${local.subdomain}"
}

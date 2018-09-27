output "kops_iam_secret_key" {
  value     = "${module.kops.iam_secret_key}"
  sensitive = true
}

output "kops_iam_access_key_id" {
  value = "${module.kops.iam_access_key_id}"
}

output "kops_state_store" {
  value = "${module.kops.state_store}"
}

output "kops_subdomain" {
  value = "${module.kops.subdomain}"
}

output "vault_bucket_name" {
  value = "${module.vault_backend.bucket_name}"
}

output "vault_aws_access_key_id" {
  value = "${module.vault_backend.aws_access_key_id}"
}

output "vault_aws_secret_access_key" {
  value     = "${module.vault_backend.aws_secret_access_key}"
  sensitive = true
}

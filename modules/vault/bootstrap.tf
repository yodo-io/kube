data "template_file" "values_yaml" {
  template = "${file("${path.module}/values.yaml")}"

  vars {
    aws_secret_access_key = "${aws_iam_access_key.vault_backend.secret}"
    aws_access_key_id     = "${aws_iam_access_key.vault_backend.id}"
    aws_s3_bucket         = "${aws_s3_bucket.vault_backend.bucket}"
    aws_region            = "${data.aws_region.current.name}"
  }
}

resource "local_file" "values_yaml" {
  content  = "${data.template_file.values_yaml.rendered}"
  filename = "${var.output_dir}/vault/values.yaml"
}

resource "local_file" "vault_sh" {
  content  = "${file("${path.module}/vault.sh")}"
  filename = "${var.output_dir}/vault/vault.sh"
}

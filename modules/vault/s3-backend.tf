resource "aws_s3_bucket" "vault_backend" {
  bucket = "${var.project_name}-vault-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  tags = "${local.tags}"
}

resource "aws_iam_user" "vault_backend" {
  name = "${var.project_name}-vault"
  path = "/${var.project_name}/"
}

resource "aws_iam_user_policy" "policy" {
  name   = "${var.project_name}-vault"
  user   = "${aws_iam_user.vault_backend.name}"
  policy = "${data.aws_iam_policy_document.vault_backend.json}"
}

data "aws_iam_policy_document" "vault_backend" {
  # allow listing of all buckets
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:HeadBucket",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "2"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }

  statement {
    sid = "3"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }
}

resource "aws_iam_access_key" "vault_backend" {
  user = "${aws_iam_user.vault_backend.name}"
}

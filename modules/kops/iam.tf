resource "aws_iam_user" "kops" {
  name = "kops"
  path = "/"
}

resource aws_iam_user_policy_attachment "kops_user_policies" {
  count      = "${length(local.kops_policy_arns)}"
  user       = "${aws_iam_user.kops.name}"
  policy_arn = "${element(local.kops_policy_arns, count.index)}"
}

resource "aws_iam_access_key" "kops" {
  user = "${aws_iam_user.kops.name}"
}

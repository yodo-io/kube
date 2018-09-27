locals {
  subdomain = "${var.project_name}.${var.parent_domain}."
}

data "aws_route53_zone" "parent" {
  name         = "${var.parent_domain}."
  private_zone = false
}

resource "aws_route53_zone" "subdomain" {
  name = "${local.subdomain}"
}

resource "aws_route53_record" "kops_ns" {
  zone_id = "${data.aws_route53_zone.parent.zone_id}"
  name    = "${local.subdomain}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.subdomain.name_servers.0}",
    "${aws_route53_zone.subdomain.name_servers.1}",
    "${aws_route53_zone.subdomain.name_servers.2}",
    "${aws_route53_zone.subdomain.name_servers.3}",
  ]
}

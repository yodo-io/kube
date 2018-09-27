variable "output_dir" {
  default = "tf-output"
}

locals {
  output_dir = "${path.cwd}/${var.output_dir}"
}

module "kops" {
  source = "./modules/kops"

  parent_domain = "${var.parent_domain}"
  project_name  = "${var.project_name}"
}

module "vault_backend" {
  source = "./modules/vault"

  project_name = "${var.project_name}"
  output_dir   = "${local.output_dir}"
}

module "cluster-lab" {
  source = "./modules/clusters/lab.kube.yodo.io"
}

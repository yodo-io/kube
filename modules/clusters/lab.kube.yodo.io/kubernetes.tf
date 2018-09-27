output "cluster_name" {
  value = "lab.kube.yodo.io"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-lab-kube-yodo-io.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-lab-kube-yodo-io.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-lab-kube-yodo-io.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-lab-kube-yodo-io.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.ap-southeast-1a-lab-kube-yodo-io.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-lab-kube-yodo-io.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-lab-kube-yodo-io.name}"
}

output "region" {
  value = "ap-southeast-1"
}

output "vpc_id" {
  value = "${aws_vpc.lab-kube-yodo-io.id}"
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_autoscaling_group" "master-ap-southeast-1a-masters-lab-kube-yodo-io" {
  name                 = "master-ap-southeast-1a.masters.lab.kube.yodo.io"
  launch_configuration = "${aws_launch_configuration.master-ap-southeast-1a-masters-lab-kube-yodo-io.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.ap-southeast-1a-lab-kube-yodo-io.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "lab.kube.yodo.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-ap-southeast-1a.masters.lab.kube.yodo.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-ap-southeast-1a"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-lab-kube-yodo-io" {
  name                 = "nodes.lab.kube.yodo.io"
  launch_configuration = "${aws_launch_configuration.nodes-lab-kube-yodo-io.id}"
  max_size             = 3
  min_size             = 3
  vpc_zone_identifier  = ["${aws_subnet.ap-southeast-1a-lab-kube-yodo-io.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "lab.kube.yodo.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.lab.kube.yodo.io"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "a-etcd-events-lab-kube-yodo-io" {
  availability_zone = "ap-southeast-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "lab.kube.yodo.io"
    Name                 = "a.etcd-events.lab.kube.yodo.io"
    "k8s.io/etcd/events" = "a/a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "a-etcd-main-lab-kube-yodo-io" {
  availability_zone = "ap-southeast-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "lab.kube.yodo.io"
    Name                 = "a.etcd-main.lab.kube.yodo.io"
    "k8s.io/etcd/main"   = "a/a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_iam_instance_profile" "masters-lab-kube-yodo-io" {
  name = "masters.lab.kube.yodo.io"
  role = "${aws_iam_role.masters-lab-kube-yodo-io.name}"
}

resource "aws_iam_instance_profile" "nodes-lab-kube-yodo-io" {
  name = "nodes.lab.kube.yodo.io"
  role = "${aws_iam_role.nodes-lab-kube-yodo-io.name}"
}

resource "aws_iam_role" "masters-lab-kube-yodo-io" {
  name               = "masters.lab.kube.yodo.io"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.lab.kube.yodo.io_policy")}"
}

resource "aws_iam_role" "nodes-lab-kube-yodo-io" {
  name               = "nodes.lab.kube.yodo.io"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.lab.kube.yodo.io_policy")}"
}

resource "aws_iam_role_policy" "masters-lab-kube-yodo-io" {
  name   = "masters.lab.kube.yodo.io"
  role   = "${aws_iam_role.masters-lab-kube-yodo-io.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.lab.kube.yodo.io_policy")}"
}

resource "aws_iam_role_policy" "nodes-lab-kube-yodo-io" {
  name   = "nodes.lab.kube.yodo.io"
  role   = "${aws_iam_role.nodes-lab-kube-yodo-io.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.lab.kube.yodo.io_policy")}"
}

resource "aws_internet_gateway" "lab-kube-yodo-io" {
  vpc_id = "${aws_vpc.lab-kube-yodo-io.id}"

  tags = {
    KubernetesCluster = "lab.kube.yodo.io"
    Name              = "lab.kube.yodo.io"
  }
}

resource "aws_key_pair" "kubernetes-lab-kube-yodo-io-4d576c5f26ed81b60894f541c62a76a5" {
  key_name   = "kubernetes.lab.kube.yodo.io-4d:57:6c:5f:26:ed:81:b6:08:94:f5:41:c6:2a:76:a5"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.lab.kube.yodo.io-4d576c5f26ed81b60894f541c62a76a5_public_key")}"
}

resource "aws_launch_configuration" "master-ap-southeast-1a-masters-lab-kube-yodo-io" {
  name_prefix                 = "master-ap-southeast-1a.masters.lab.kube.yodo.io-"
  image_id                    = "ami-e112439d"
  instance_type               = "t2.small"
  key_name                    = "${aws_key_pair.kubernetes-lab-kube-yodo-io-4d576c5f26ed81b60894f541c62a76a5.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-lab-kube-yodo-io.id}"
  security_groups             = ["${aws_security_group.masters-lab-kube-yodo-io.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-ap-southeast-1a.masters.lab.kube.yodo.io_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-lab-kube-yodo-io" {
  name_prefix                 = "nodes.lab.kube.yodo.io-"
  image_id                    = "ami-e112439d"
  instance_type               = "t2.small"
  key_name                    = "${aws_key_pair.kubernetes-lab-kube-yodo-io-4d576c5f26ed81b60894f541c62a76a5.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-lab-kube-yodo-io.id}"
  security_groups             = ["${aws_security_group.nodes-lab-kube-yodo-io.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.lab.kube.yodo.io_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.lab-kube-yodo-io.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.lab-kube-yodo-io.id}"
}

resource "aws_route_table" "lab-kube-yodo-io" {
  vpc_id = "${aws_vpc.lab-kube-yodo-io.id}"

  tags = {
    KubernetesCluster = "lab.kube.yodo.io"
    Name              = "lab.kube.yodo.io"
  }
}

resource "aws_route_table_association" "ap-southeast-1a-lab-kube-yodo-io" {
  subnet_id      = "${aws_subnet.ap-southeast-1a-lab-kube-yodo-io.id}"
  route_table_id = "${aws_route_table.lab-kube-yodo-io.id}"
}

resource "aws_security_group" "masters-lab-kube-yodo-io" {
  name        = "masters.lab.kube.yodo.io"
  vpc_id      = "${aws_vpc.lab-kube-yodo-io.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "lab.kube.yodo.io"
    Name              = "masters.lab.kube.yodo.io"
  }
}

resource "aws_security_group" "nodes-lab-kube-yodo-io" {
  name        = "nodes.lab.kube.yodo.io"
  vpc_id      = "${aws_vpc.lab-kube-yodo-io.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "lab.kube.yodo.io"
    Name              = "nodes.lab.kube.yodo.io"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  source_security_group_id = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-lab-kube-yodo-io.id}"
  source_security_group_id = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-lab-kube-yodo-io.id}"
  source_security_group_id = "${aws_security_group.nodes-lab-kube-yodo-io.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "https-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-lab-kube-yodo-io.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  source_security_group_id = "${aws_security_group.nodes-lab-kube-yodo-io.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  source_security_group_id = "${aws_security_group.nodes-lab-kube-yodo-io.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  source_security_group_id = "${aws_security_group.nodes-lab-kube-yodo-io.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  source_security_group_id = "${aws_security_group.nodes-lab-kube-yodo-io.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-lab-kube-yodo-io.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-lab-kube-yodo-io.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "ap-southeast-1a-lab-kube-yodo-io" {
  vpc_id            = "${aws_vpc.lab-kube-yodo-io.id}"
  cidr_block        = "10.20.32.0/19"
  availability_zone = "ap-southeast-1a"

  tags = {
    KubernetesCluster                        = "lab.kube.yodo.io"
    Name                                     = "ap-southeast-1a.lab.kube.yodo.io"
    "kubernetes.io/cluster/lab.kube.yodo.io" = "owned"
    "kubernetes.io/role/elb"                 = "1"
  }
}

resource "aws_vpc" "lab-kube-yodo-io" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                        = "lab.kube.yodo.io"
    Name                                     = "lab.kube.yodo.io"
    "kubernetes.io/cluster/lab.kube.yodo.io" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "lab-kube-yodo-io" {
  domain_name         = "ap-southeast-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster = "lab.kube.yodo.io"
    Name              = "lab.kube.yodo.io"
  }
}

resource "aws_vpc_dhcp_options_association" "lab-kube-yodo-io" {
  vpc_id          = "${aws_vpc.lab-kube-yodo-io.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.lab-kube-yodo-io.id}"
}

terraform = {
  required_version = ">= 0.9.3"
}

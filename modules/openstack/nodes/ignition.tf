data "ignition_config" "node" {
  count = "${var.instance_count}"

  users = [
    "${data.ignition_user.core.id}",
  ]

  files = [
    "${data.ignition_file.kubeconfig.id}",
    "${var.ign_installer_kubelet_env_id}",
    "${var.ign_max_user_watches_id}",
    "${data.ignition_file.resolv_conf.id}",
    "${data.ignition_file.hostname.*.id[count.index]}",
    "${data.ignition_file.sshd.id}",
  ]

  systemd = ["${compact(list(
    var.ign_docker_dropin_id,
    var.ign_k8s_node_bootstrap_service_id,
    var.ign_locksmithd_service_id,
    var.ign_kubelet_service_id,
    var.ign_bootkube_service_id,
    var.ign_tectonic_service_id,
    var.ign_bootkube_path_unit_id,
    var.ign_tectonic_path_unit_id,
   ))}"]
}

data "ignition_file" "resolv_conf" {
  path       = "/etc/resolv.conf"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.resolv_conf_content}"
  }
}

data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.core_public_keys}"]
}

data "ignition_file" "hostname" {
  count      = "${var.instance_count}"
  path       = "/etc/hostname"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.cluster_name}-${var.hostname_infix}-${count.index}"
  }
}

data "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = 0644

  content {
    content = "${var.kubeconfig_content}"
  }
}

data "ignition_file" "sshd" {
  filesystem = "root"
  path       = "/etc/ssh/sshd_config"
  mode       = 0600

  content {
    content = <<EOF
UsePrivilegeSeparation sandbox
Subsystem sftp internal-sftp

PermitRootLogin no
AuthenticationMethods publickey
EOF
  }
}

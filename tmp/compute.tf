data "template_file" "cloud-init" {
  template = "${file("${path.module}/files/cloud-init.yaml")}"
  vars = {
    username = "${var.username}"
    ssh_public_key = "${var.ssh_public_key}"
  }
}

data "template_cloudinit_config" "config" {
    gzip          = true
    base64_encode = true
    part {
        content_type = "text/cloud-config"
        content      = "${data.template_file.cloud-init.rendered}"
    }
}

resource "yandex_compute_disk" "bastion" {
    name     = "bastion"
    type     = "network-hdd"
    zone     = "ru-central1-a"
    image_id = var.image
    size     = 10
}

resource "yandex_compute_instance" "bastion" {
    name                      = "bastion"
    hostname                  = "bastion"
    zone                      = "ru-central1-a"
    platform_id               = "standard-v3"

    resources {
        cores  = 2
        memory = 2
        core_fraction = 20
    }

    boot_disk {
        disk_id     = "${yandex_compute_disk.bastion.id}"
    }

    network_interface {
        subnet_id           = yandex_vpc_subnet.private_network_a.id
        nat                 = true
        ip_address          = "10.10.1.10"
        security_group_ids  = [
            yandex_vpc_security_group.bastion.id
        ]
    }

    metadata = {
        user-data = data.template_cloudinit_config.config.rendered
    }

    scheduling_policy {
        preemptible = true
    }
}
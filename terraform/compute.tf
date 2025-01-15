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
    zone     = "ru-central1-d"
    image_id = var.image
    size     = 10
}

resource "yandex_compute_instance" "bastion" {
    name                      = "bastion"
    hostname                  = "bastion"
    zone                      = "ru-central1-d"
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
        subnet_id           = yandex_vpc_subnet.private_network_d.id
        nat                 = true
        ip_address          = "10.10.4.10"
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

resource "yandex_compute_disk" "zabbix" {
    name     = "zabbix"
    type     = "network-hdd"
    zone     = "ru-central1-d"
    image_id = var.image
    size     = 10
}

resource "yandex_compute_instance" "zabbix" {
    name                      = "zabbix"
    hostname                  = "zabbix"
    zone                      = "ru-central1-d"
    allow_stopping_for_update = true
    platform_id               = "standard-v3"

    resources {
        cores  = 2
        memory = 2
        core_fraction = 20
    }

    boot_disk {
        disk_id     = "${yandex_compute_disk.zabbix.id}"
    }

    network_interface {
        subnet_id           = yandex_vpc_subnet.private_network_d.id
        nat                 = true
        ip_address          = "10.10.4.11"
        security_group_ids  = [
            yandex_vpc_security_group.ssh.id,
            yandex_vpc_security_group.zabbix.id
        ]
    }

    metadata = {
        user-data = data.template_cloudinit_config.config.rendered
    }

    scheduling_policy {
        preemptible = true
    }
}

resource "yandex_compute_disk" "elastic" {
    name     = "elastic"
    type     = "network-hdd"
    zone     = "ru-central1-d"
    image_id = var.image
    size     = 20
}

resource "yandex_compute_instance" "elastic" {
    name                      = "elastic"
    hostname                  = "elastic"
    zone                      = "ru-central1-d"
    allow_stopping_for_update = true
    platform_id               = "standard-v3"

    resources {
        cores  = 2
        memory = 4
        core_fraction = 20
    }

    boot_disk {
        disk_id     = "${yandex_compute_disk.elastic.id}"
    }

    network_interface {
        subnet_id           = yandex_vpc_subnet.private_network_d.id
        nat                 = false
        ip_address          = "10.10.4.12"
        security_group_ids = [
            yandex_vpc_security_group.ssh.id,
            yandex_vpc_security_group.elastic.id
        ]
    }

    metadata = {
        user-data = data.template_cloudinit_config.config.rendered
    }

    scheduling_policy {
        preemptible = true
    }
}

resource "yandex_compute_disk" "kibana" {
    name     = "kibana"
    type     = "network-hdd"
    zone     = "ru-central1-b"
    image_id = var.image
    size     = 10
}

resource "yandex_compute_instance" "kibana" {
    name                      = "kibana"
    hostname                  = "kibana"
    zone                      = "ru-central1-b"
    allow_stopping_for_update = true
    platform_id               = "standard-v3"

    resources {
        cores  = 2
        memory = 2
        core_fraction = 20
    }

    boot_disk {
        disk_id     = "${yandex_compute_disk.kibana.id}"
    }

    network_interface {
        subnet_id           = yandex_vpc_subnet.private_network_b.id
        nat                 = true
        ip_address          = "10.10.2.10"
        security_group_ids  = [
            yandex_vpc_security_group.ssh.id,
            yandex_vpc_security_group.kibana.id
        ]
    }

    metadata = {
        user-data = data.template_cloudinit_config.config.rendered
    }

    scheduling_policy {
        preemptible = true
    }
}

resource "yandex_compute_disk" "backend_1" {
    name     = "backned-1"
    type     = "network-hdd"
    zone     = "ru-central1-a"
    image_id = var.image
    size     = 10
}

resource "yandex_compute_instance" "backend_1" {
    name                      = "backend_1"
    hostname                  = "backend-1"
    zone                      = "ru-central1-a"
    allow_stopping_for_update = true
    platform_id               = "standard-v3"

    resources {
        cores  = 2
        memory = 2
        core_fraction = 20
    }

    boot_disk {
        disk_id     = "${yandex_compute_disk.backend_1.id}"
    }

    network_interface {
        subnet_id           = yandex_vpc_subnet.private_network_a.id
        nat                 = false
        ip_address          = "10.10.1.10"
        security_group_ids  = [
            yandex_vpc_security_group.ssh.id,
            yandex_vpc_security_group.backend.id
        ]
    }

    metadata = {
        user-data = data.template_cloudinit_config.config.rendered
    }

    scheduling_policy {
        preemptible = true
    }
}

resource "yandex_compute_disk" "backend_2" {
    name     = "backned-2"
    type     = "network-hdd"
    zone     = "ru-central1-b"
    image_id = var.image
    size     = 10
}

resource "yandex_compute_instance" "backend_2" {
    name                      = "backend_2"
    hostname                  = "backend-2"
    zone                      = "ru-central1-b"
    allow_stopping_for_update = true
    platform_id               = "standard-v3"

    resources {
        cores  = 2
        memory = 2
        core_fraction = 20
    }

    boot_disk {
        disk_id     = "${yandex_compute_disk.backend_2.id}"
    }

    network_interface {
        subnet_id           = yandex_vpc_subnet.private_network_b.id
        nat                 = false
        ip_address          = "10.10.2.11"
        security_group_ids  = [
            yandex_vpc_security_group.ssh.id,
            yandex_vpc_security_group.backend.id
        ]
    }

    metadata = {
        user-data = data.template_cloudinit_config.config.rendered
    }

    scheduling_policy {
        preemptible = true
    }
}
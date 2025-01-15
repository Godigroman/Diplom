resource "yandex_vpc_security_group" "bastion" {
    name        = "bastion"
    network_id  = "${yandex_vpc_network.main.id}"  
    ingress {
        protocol          = "TCP"
        description       = "ssh"
        port              = 22
        v4_cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
    
    ingress {
        protocol       = "TCP"
        description    = "zabbix"
        port           = 10050
        v4_cidr_blocks = [
            var.private_network_d_cidr
        ]
    }

    egress {
        protocol          = "ANY"
        v4_cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
}

resource "yandex_vpc_security_group" "ssh" {
    name       = "ssh"
    network_id = yandex_vpc_network.main.id
    ingress {
        protocol       = "TCP"
        port           = 22
        v4_cidr_blocks = [
            var.private_network_a_cidr,
            var.private_network_b_cidr,
            var.private_network_d_cidr
        ]
    }

    ingress {
        protocol       = "ICMP"
        v4_cidr_blocks = [
            var.private_network_a_cidr,
            var.private_network_b_cidr,
            var.private_network_d_cidr
        ]
    }
}

resource "yandex_vpc_security_group" "backend" {
    name        = "backend"
    network_id  = "${yandex_vpc_network.main.id}"  

    ingress {
        protocol       = "TCP"
        port           = 80
        v4_cidr_blocks = [
            var.private_network_a_cidr,
            var.private_network_b_cidr,
            var.private_network_d_cidr
        ]
    }

    ingress {
        protocol       = "TCP"
        description    = "zabbix"
        port           = 10050
        v4_cidr_blocks = [
            var.private_network_d_cidr
        ]
    }

    ingress {
        protocol = "TCP"
        predefined_target = "loadbalancer_healthchecks" 
    }

    egress {
        protocol       = "ANY"
        v4_cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
}

resource "yandex_vpc_security_group" "kibana" {
    name        = "kibana"
    network_id  = "${yandex_vpc_network.main.id}"  

    ingress {
        protocol       = "TCP"
        port           = 5601
        v4_cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

    ingress {
        protocol       = "TCP"
        description    = "zabbix"
        port           = 10050
        v4_cidr_blocks = [
            var.private_network_d_cidr
        ]
    }

    egress {
        protocol       = "ANY"
        v4_cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
}

resource "yandex_vpc_security_group" "zabbix" {
    name        = "zabbix"
    network_id  = "${yandex_vpc_network.main.id}"  

    ingress {
        protocol       = "TCP"
        port           = 8080
        v4_cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

    ingress {
        protocol       = "TCP"
        port           = 10051
        v4_cidr_blocks = [
            var.private_network_a_cidr,
            var.private_network_b_cidr,
            var.private_network_d_cidr
        ]
    }

    egress {
        protocol       = "ANY"
        v4_cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
}

resource "yandex_vpc_security_group" "elastic" {
  name        = "elastic"
  network_id  = "${yandex_vpc_network.main.id}"  

    ingress {
        protocol       = "TCP"
        description    = "zabbix"
        port           = 10050
        v4_cidr_blocks = [
            var.private_network_d_cidr
        ]
    }

    ingress {
        protocol       = "TCP"
        description    = "elastic agent in"
        port           = 9200
        v4_cidr_blocks = [
            var.private_network_a_cidr,
            var.private_network_b_cidr,
            var.private_network_d_cidr
        ]
    }

    egress {
        protocol       = "ANY"
        v4_cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
}
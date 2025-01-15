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

    egress {
        protocol          = "ANY"
        v4_cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
}
resource "yandex_vpc_network" "main" {
    name = "main"
}

resource "yandex_vpc_gateway" "private_gw" {
    name = "gateway"
    shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private_rt" {
    name       = "routing-table"
    network_id = yandex_vpc_network.main.id

    static_route {
        destination_prefix = "0.0.0.0/0"
        gateway_id         = yandex_vpc_gateway.private_gw.id
    }
}

resource "yandex_vpc_subnet" "private_network_a" {
    name           = "private-network-a"
    zone           = "ru-central1-a"
    network_id     = yandex_vpc_network.main.id
    v4_cidr_blocks = [
        var.private_network_a_cidr
    ]
    route_table_id = yandex_vpc_route_table.private_rt.id
}
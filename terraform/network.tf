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

resource "yandex_vpc_subnet" "private_network_b" {
    name           = "private-network-b"
    zone           = "ru-central1-b"
    network_id     = yandex_vpc_network.main.id
    v4_cidr_blocks = [
        var.private_network_b_cidr
    ]
    route_table_id = yandex_vpc_route_table.private_rt.id
}

resource "yandex_vpc_subnet" "private_network_d" {
    name           = "private-network-d"
    zone           = "ru-central1-d"
    network_id     = yandex_vpc_network.main.id
    v4_cidr_blocks = [
        var.private_network_d_cidr
    ]
    route_table_id = yandex_vpc_route_table.private_rt.id
}

resource "yandex_alb_http_router" "alb" {
    name      = "apploadbalancer"
}

resource "yandex_alb_target_group" "alb_target_group" {
    name            = "alb-target-group"

    target {
        subnet_id   = "${yandex_vpc_subnet.private_network_a.id}"
        ip_address  = "${yandex_compute_instance.backend_1.network_interface.0.ip_address}"
    }

    target {
        subnet_id   = "${yandex_vpc_subnet.private_network_b.id}"
        ip_address  = "${yandex_compute_instance.backend_2.network_interface.0.ip_address}"
    }
}

resource "yandex_alb_backend_group" "nginx_backend" {
    name      = "nginx-backend"

    http_backend {
        name = "backend"
        port = 80
        weight = 1
        target_group_ids = [
            yandex_alb_target_group.alb_target_group.id
        ]
        
        load_balancing_config {
            panic_threshold = 0
        }    
        healthcheck {
            interval = "3s"
            timeout = "1s"
            healthy_threshold    = 2
            unhealthy_threshold  = 2 
            healthcheck_port     = 80
            http_healthcheck {
                path  = "/"
            }
        }
    }
}

resource "yandex_alb_virtual_host" "alb_vhost" {
    name                            = "nginx"
    http_router_id                  = yandex_alb_http_router.alb.id
    route {
        name                        = "nginx"
        http_route {
            http_route_action {
                backend_group_id    = yandex_alb_backend_group.nginx_backend.id
            }
        }
    }
}    

resource "yandex_alb_load_balancer" "alb_balancer" {
    name        = "nginx"
    network_id  = yandex_vpc_network.main.id

    allocation_policy {
        location {
            zone_id   = "ru-central1-a"
            subnet_id = yandex_vpc_subnet.private_network_a.id 
        }
        location {
            zone_id   = "ru-central1-b"
            subnet_id = yandex_vpc_subnet.private_network_b.id 
        }
    
        location {
            zone_id   = "ru-central1-d"
            subnet_id = yandex_vpc_subnet.private_network_d.id 
        }
    }

    listener {
        name = "listener"
        endpoint {
            address {
                external_ipv4_address {}
            }
            ports = [ 80 ]
        }    
        http {
            handler {
                http_router_id = yandex_alb_http_router.alb.id
            }
        }
    }
}
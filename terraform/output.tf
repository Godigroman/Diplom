output "bastion_public_ip" {
    value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "kibana_public_ip" {
    value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "zabbix_public_ip" {
    value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "bastion_internal_fqdn" {
    value = yandex_compute_instance.bastion.fqdn
}

output "zabbix_internal_fqdn" {
    value = yandex_compute_instance.zabbix.fqdn
}

output "elastic_internal_fqdn" {
    value = yandex_compute_instance.elastic.fqdn
}

output "kibana_internal_fqdn" {
    value = yandex_compute_instance.kibana.fqdn
}

output "backend-1_internal_fqdn" {
    value = yandex_compute_instance.backend_1.fqdn
}

output "backend-2_internal_fqdn" {
    value = yandex_compute_instance.backend_2.fqdn
}
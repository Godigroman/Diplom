resource "local_file" "hosts" {
    content  = <<-EOT
        [all:vars]
        ansible_ssh_user=user
        ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -q user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
        
        [elk:children]
        backend
        elastic
        kibana

        [elk:vars]
        elk_version="7.15.1"

        [bastion]
        ${yandex_compute_instance.bastion.fqdn}

        [zabbix]
        ${yandex_compute_instance.zabbix.fqdn}

        [zabbix:vars]
        zabbix_server=127.0.0.1

        [backend]
        ${yandex_compute_instance.backend_1.fqdn}
        ${yandex_compute_instance.backend_2.fqdn}

        [elastic]
        ${yandex_compute_instance.elastic.fqdn}

        [kibana]
        ${yandex_compute_instance.kibana.fqdn}
        EOT
    filename = "../ansible/hosts"
}
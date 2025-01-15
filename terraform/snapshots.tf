resource "yandex_compute_snapshot_schedule" "snapshots" {
    name          = "snapshots"

    schedule_policy {
        expression = "0 0 * * *"
    }

    retention_period = "168h"

    snapshot_spec {
        description = "retention-snapshot"
    }

    disk_ids = [
        yandex_compute_disk.backend_1.id,
        yandex_compute_disk.backend_2.id,
        yandex_compute_disk.bastion.id,
        yandex_compute_disk.zabbix.id,
        yandex_compute_disk.elastic.id,
        yandex_compute_disk.kibana.id,
    ]

    depends_on = [
        yandex_compute_instance.backend_1,
        yandex_compute_instance.backend_2,
        yandex_compute_instance.bastion,
        yandex_compute_instance.zabbix,
        yandex_compute_instance.elastic,
        yandex_compute_instance.kibana
    ]
}
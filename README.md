# Разработка инфраструктуры для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных - `Клименко Олег`

# Сайт
Две виртуаьные машины созданы в различных зонах для достижения распределённости и отказоустойчивости:

- ru-central1-a
- ru-central1-b

На вебсервера установлено следующее ПО:

- NGINX в качестве вебсервера
- Filebeat для сбора и передачи логов в elasticsearch
- Zabbix-agent для сбора и отправки метрик на zabbix-server

Виртуальные машины не обладают внешним IP для уменьшения площади атаки извне. Для доступа к вебсерверам используется бастион хост, находящийся во внешнем контуре сети. Доступ к веб-порту обеспечивается через балансировщик yamdex cloud, который одновременно занимается и балансировкой трафика не вебсервера.

1. Настройки балансировщика:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321814690485112862/image.png?ex=676e9b5c&is=676d49dc&hm=cbee2303945cb157c6fc3324dfca1e0e8bd19b9e5b3cb78a2cc7d3bcf2139301&)

2. Создана группа бекенда:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321815227951484951/image.png?ex=676e9bdc&is=676d4a5c&hm=dd1882c7511ad793cc028c19d27de1b0073d88dd5fb0e47db8cef0ed53ae7d84&)

3. Создан HTTP роутер:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321815437696303125/image.png?ex=676e9c0e&is=676d4a8e&hm=a3dc459fcac92d2fac12333e40191a858affe05f092c1050999e66a12f35bdc1&)

4. Создан балансировщик и listener:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321815762024927304/image.png?ex=676e9c5b&is=676d4adb&hm=61273ec06ff4f759648818613d162e1ef28fc55271886b7e40a8d06bbd9067f5&)

Карта балансировки выглядит следующим образом:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321816261373464607/image.png?ex=676e9cd2&is=676d4b52&hm=f5edf98b8f6d32cfc82c2c17cf54254e0995effc70006bd6c16957e342f55316&)

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321816663137583124/image.png?ex=676e9d32&is=676d4bb2&hm=51f9d9a18c69d5d75cb3fbd0e2ff62e2695f5c66f1403fc1cb890758869d690c&)

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321816805865685066/image.png?ex=676e9d54&is=676d4bd4&hm=12b9145c0d4f38b1eedb670a8d63b2427dade67473801b3c031d1d83dc8020e1&)

Конфигурационный файл filebeat:

```
filebeat.inputs:
  - type: log
    enabled: true

    paths:
      - /var/log/nginx/access.log

  - type: log
    enabled: true

    paths:
      - /var/log/nginx/error.log

output.elasticsearch:
  hosts: ["10.120.0.23:9200"]
  protocol: http
  index: "WEBS-%{+yyyy.MM.dd}"
  username: "elastic"
  password: "changed_password"

setup.kibana:
  host: ["10.122.0.30:5601"]

setup.ilm.enabled: false

setup.template.name: "filebeat"
setup.template.pattern: "filebeat"
setup.template.settings:
  index.number_of_shards: 1
```

---

# Мониторинг

Мониторинг осуществляется при помощи Zabbix. Для zabbix-server создана отдельная виртуальная машина, находящаяся во внешнем контуре сети. На данную машину отправляются метрики с хостов вебсерверов.

Конфигурационный файл zabbix-server:

```
LogFile=/var/log/zabbix/zabbix_server.log

LogFileSize=0

PidFile=/run/zabbix/zabbix_server.pid

SocketDir=/run/zabbix

DBName=zabbix

DBUser=zabbix

DBPassword=changed_password

SNMPTrapperFile=/var/log/snmptrap/snmptrap.log

Timeout=4

FpingLocation=/usr/bin/fping

Fping6Location=/usr/bin/fping6

LogSlowQueries=3000

StatsAllowedIP=127.0.0.1

EnableGlobalScripts=0
```

Для сбора метрик настроены хосты в веб интерфейсе:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321820100055138325/image.png?ex=676ea066&is=676d4ee6&hm=8c4c90f2584ba98d3156b63390083e82bcd6153b6730979855a3d9d44b8b82bb&)

Созданы следующие дашборды:

1. Главная страница с основной информацией:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321820451508584541/image.png?ex=676ea0b9&is=676d4f39&hm=7a4f8cb061ff40dcacfeb3dbd9f934e7574b7f9b0b0b2623463a32a56daa8f82&)

2. Страница с информацией о дисковых системах:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321826737277108257/image.png?ex=676ea694&is=676d5514&hm=9a91bfae64d7a420e3f1e443a34c6dfbc839cfff47b61c90962fabcc3f8904f3&)

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321826901370605629/image.png?ex=676ea6bb&is=676d553b&hm=8ffe5a30ea5fe1385f30e01796bcddc35b163f5a863ac25dc4490cb99ef4cecd&)

3. Страница с информацией о сети:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321827029871497247/image.png?ex=676ea6da&is=676d555a&hm=bd283e2b3451bbdc054773770fe23eaec779abb4e89c5bc4a4476c9568adf8c2&)

4. Страница с информацией об ОЗУ:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321827143700844666/image.png?ex=676ea6f5&is=676d5575&hm=a257c7ea6fa3ae150cfb595bb9046048e306aae637d282ac5a6c48fab95b1489&)

5. Страница с информацией о ЦПУ:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321827288337088522/image.png?ex=676ea717&is=676d5597&hm=5687b61fd9ce83aeb5839873ba2f3748899800951b4141b17049439df037d4e4&)

---

# Логи

Сбор логов осушествляется в 3 этапа:

1. Сбор логов на хостах.
2. Отправка логов на сервер elasticsearch.
3. Обработка логов на сервере elasticsearch.

Далее для визуализации данных сервер Kibana запрашивает и получает данные с сервера elasticsearch. Для визуализации данных необходимо:

1. Создать шаблон считываемых индексов:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321827468792954901/image.png?ex=676ea742&is=676d55c2&hm=42f07eb789d7bb41b958270abb90fdc83e5006bf4368a929508ece45b350b09a&)

1.1 Под этот шаблон подпадают следующие индексы:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321827584673316865/image.png?ex=676ea75e&is=676d55de&hm=240a16a9ed8247b8acf6a86fd59b46ad9538b0bdc068cc549067de8db63089cd&)

2. Далее необходимо проанализировать какие поля присутствуют в логах:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321827688188739666/image.png?ex=676ea777&is=676d55f7&hm=5ffe41fdd1fcd5b1b4788392915751f576037ac27c4bb6b40bb33c8a1c76a0d7&)

3. На основании полей построить дашборд:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321827798868037643/image.png?ex=676ea791&is=676d5611&hm=16e0b000bc80b4341ac5cab0e085dd5ea5c12ede2647f38b8e40fab04a8a02ca&)

В дашборде присутствует диаграмма, в которой показывается разделение логов по типу лога и по типу хоста. А также диаграмма кривой количества запросов к каждой машине ко времени.

Конфигурационный файл elasticsearch:

```
cluster.name: websites

path.data: /var/lib/elasticsearch

path.logs: /var/log/elasticsearch

network.host: 0.0.0.0

discovery.type: single-node

xpack.security.enabled: true
xpack.license.self_generated.type: basic

```

Конфигурационный файл kibana:

```
server.name: "kibana"
server.host: 10.122.0.30
server.port: 5601
server.publicBaseUrl: "http://84.201.178.82:5601"

elasticsearch.hosts: 
  - http://10.120.0.23:9200

elasticsearch.username: "elastic"
elasticsearch.password: "changed_password"

logging.dest: /var/log/kibana/kibana.log

```

---

# Сеть

Принципиальная схема взаимодействия хостов в сети:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321828002610417715/image.png?ex=676ea7c2&is=676d5642&hm=393513b8cfae86bd7a0fa0e970117ea21f5bfbe2c19e057dd5c1da792eabac8c&)

Хосты web1, web2, elasticsearch не имеют прямого доступа к внешней сети. Все общение происходит через сервера посредники - bastion (NAT gateway) и балансировщик. Для этого бы настроен gateway через bastion host и таблица маршрутизации:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321828194185117787/image.png?ex=676ea7ef&is=676d566f&hm=87c07674dd012fc05d0872141b9e7a8407a51a905ffb3fec62bee7ad4148d41b&)

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321828314926678027/image.png?ex=676ea80c&is=676d568c&hm=b5c2cb27071f9ce5b3d5e9d44b7a951c19778318ba47a7e6176fc9c387afaef8&)

Подключение к хостам по ssh происходит через бастион в качестве jump сервера и используется fqdn имена виртуальных машин в зоне:

```
ssh -J bastion@51.250.19.231 admin@web1.ru-central1.internal
```

Схема сети VPC в yandex cloud:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321828460938924093/image.png?ex=676ea82f&is=676d56af&hm=4492fa52ed307fdf682b7942179cc95d7092e6b167f93a882ec53b1e37b3d509&)

Подсети VPC в yandex cloud:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321828590798770197/image.png?ex=676ea84e&is=676d56ce&hm=2f5a7592caa524ad20265bfa57dfada9851c70b49980018fc087df737a9db631&)

Также были настроены различные группы безопасности предоставляющие доступ только к необходимым портам:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321828704879378453/image.png?ex=676ea869&is=676d56e9&hm=1a26ccb4703bbda4e45793587e1990834b58de4762e6d04f359989f39965ba99&)

Подробнее о каждой группе:

1. Elastic

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321828866364280874/image.png?ex=676ea890&is=676d5710&hm=5925dd1f0bed0d2bf3a25a997420183baec992c2a5d5aa3e8a39d5e338068cf9&)

2. For_web

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321828993061748736/image.png?ex=676ea8ae&is=676d572e&hm=93094a82c0aaa9a6041fb0535c18e6c4dd3810e184adf8420dca6e75b00b69df&)

3. http

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321829144027463720/image.png?ex=676ea8d2&is=676d5752&hm=16f7d82f65319f7bedee59493de058de871e1d4042becf129ecf69a19bcd77c3&)

4. kibana

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321829277347610634/image.png?ex=676ea8f2&is=676d5772&hm=221cb62f18352a83464f90717e0ccbed30b07f279ea7674ad1017a7022cf4c35&)

5. ssh

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321829420364857385/image.png?ex=676ea914&is=676d5794&hm=0325e3f6789c074a511f99ba5cf774b18c2ef88c73cd5cbadec6aa1a5b1f47f9&)

6. zabbix

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321829543258095646/image.png?ex=676ea931&is=676d57b1&hm=d84bb2f8bc8962fbf6c4cac0643f1e4b2d382d0134f5b5cc90d1e12180b27bfd&)

---

# Резервное копирование

Резервное копирование производилось встроенным инструментом yandex backup cloud.

Была настроена политика бэкапов:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321829672345931806/image.png?ex=676ea950&is=676d57d0&hm=534ab471a5ccf777d072ba166eaecd221557543947429039f0db3a6dd57bb999&)

В качестве вида бэкапов выбраны инкрементные бэкапы. После этого все виртуальные машины были подкючены к этой политике резервного копирования, после чего был снят первый (полный) бэкап:

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321829801937473577/image.png?ex=676ea96f&is=676d57ef&hm=603602abfca93cd940dcf03352031a71f5922c8bd85f9211345b594b51fc68e2&)

---

# Развертывание серверов и приожений на серверах

Развертывание приложений происходило при помощи terraform и API yandex cloud. Этот файл также лежит в этой ветке.

Развертывание приложений происходило при помощи ansible, который был установлен на bastion host. Этот файл также лежит в этой ветке.

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321829959492177970/image.png?ex=676ea994&is=676d5814&hm=82818ce7b8c7b97255fb302099ac09c503e987400061fd80b8e0ca6705e4ed07&)

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321830090170175588/image.png?ex=676ea9b3&is=676d5833&hm=5b4951b9df2f531b511e9e1b10b2fb58993d73ed23c4fcd95e549b4249999121&)

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321830212950032405/image.png?ex=676ea9d1&is=676d5851&hm=0bce195f0c4fc64d01e1c038cc2b4775311807543ec2d5f12552acf0bf4d0065&)

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321830337478922332/image.png?ex=676ea9ee&is=676d586e&hm=a544824c8b930f8cff0d4cb3821ae73d18532dec05d0017271007bef45a8782b&)

![](https://cdn.discordapp.com/attachments/1306218954586591242/1321830486204616745/image.png?ex=676eaa12&is=676d5892&hm=577a615e12abf40ef53f161b235e3bfc486b2731eb7b42d2a622771fec76b80d&)

---

# Ansible

inventory

```
[Sites_group]
web1.ru-central1.internal ansible_user=admin
web2.ru-central1.internal ansible_user=admin
[Zabbix_group]
zabbix.ru-central1.internal ansible_user=admin
[ELK_group]
elasticsearch.ru-central1.internal ansible_user=admin
[Kibana_group]
kibana.ru-central1.internal ansible_user=admin
```

playbook.yml

```
---

- name: configurate frontend servers
  hosts: Sites_group
  become: yes
  vars:
    beats_gpg: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'

  tasks:
  - name: update apt 
    apt:
      update_cache: yes
      upgrade: yes
  - name: search and istall nginx
    apt:
      name: nginx
      state: present
  - name: start application
    systemd: 
      name: nginx
      state: started
  - name: add nginx to autoload
    systemd: 
      name: nginx
      enabled: yes
  

  - name: install gnupg
    apt:
      name: gnupg
      state: present
  - name: install apt-transport-https
    apt:
      name: apt-transport-https
      state: present
  - name: get GPG
    ansible.builtin.shell:
      cmd: wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/elastic-7.x.gpg --import
  - name: add gpg
    ansible.builtin.shell:
      cmd: sudo chmod 644 /etc/apt/trusted.gpg.d/elastic-7.x.gpg
  - name: Add Beats apt repository.
    ansible.builtin.shell:
      cmd: echo "deb [trusted=yes] https://mirror.yandex.ru/mirrors/elastic/7/ stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
  - name: update apt 
    apt:
      update_cache: yes 
  - name: install filebeat
    apt:
      name: filebeat
      state: present
  - name: add filebeat to autoload
    systemd: 
      name: filebeat
      enabled: yes

- name: installing zabbix agent 
  hosts: Sites_group
  become: yes
  tasks:
  - name: search and istall zabbix-agent
    apt:
      name: zabbix-agent
      state: present
  - name: start application
    systemd: 
      name: zabbix-agent
      state: started
  - name: add to autoload
    systemd: 
      name: zabbix-agent
      enabled: yes

- name: configurate zabbix server 
  hosts: Zabbix_group
  become: yes
  vars:
    get_zabbix_pkg: 'https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb'
    zabbix_pkg: 'zabbix-release_7.0-2+ubuntu22.04_all.deb'
  tasks:

  - name: update apt 
    apt:
      update_cache: yes
      upgrade: yes

  - name: search and istall postgresql
    apt:
      name: postgresql
      state: present
  - name: start application
    systemd: 
      name: postgresql
      state: started
  - name: add to autoload
    systemd: 
      name: postgresql
      enabled: yes

  - name: getting zabbix pkg
    ansible.builtin.shell:
      cmd: wget "{{ get_zabbix_pkg }}"
  - name: building zabbix pkg
    ansible.builtin.shell:
      cmd: dpkg -i "{{ zabbix_pkg }}"


  - name: update apt 
    apt:
      update_cache: yes

  - name: downloading zabbix-server-pgsql
    apt:
      name: zabbix-server-pgsql
      state: present

  - name: downloading zabbix-frontend-php
    apt:
      name: zabbix-frontend-php
      state: present

  - name: downloading php8.1-pgsql
    apt:
      name: php8.1-pgsql
      state: present

  - name: downloading zabbix-apache-conf
    apt:
      name: zabbix-apache-conf
      state: present

  - name: downloading zabbix-sql-scripts
    apt:
      name: zabbix-sql-scripts
      state: present

  - name: downloading zabbix-agent
    apt:
      name: zabbix-agent
      state: present

- name: configurate elk machine
  hosts: ELK_group
  become: yes
  vars:
    beats_gpg: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'

  tasks:

  - name: update apt 
    apt:
      update_cache: yes
      upgrade: yes
  - name: install gnupg
    apt:
      name: gnupg
      state: present
  - name: install apt-transport-https
    apt:
      name: apt-transport-https
      state: present
  - name: get GPG
    ansible.builtin.shell:
      cmd: wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/elastic-7.x.gpg --import
  - name: add gpg
    ansible.builtin.shell:
      cmd: sudo chmod 644 /etc/apt/trusted.gpg.d/elastic-7.x.gpg
  - name: Add elk apt repository.
    ansible.builtin.shell:
      cmd: echo "deb [trusted=yes] https://mirror.yandex.ru/mirrors/elastic/7/ stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
  - name: update apt 
    apt:
      update_cache: yes 
  - name: install elasticsearch
    apt:
      name: elasticsearch
      state: present
  - name: update systemd configs
    ansible.builtin.shell:
      cmd: systemctl daemon-reload
  - name: enable unit
    ansible.builtin.shell:
      cmd: systemctl enable elasticsearch.service
  - name: start unit
    ansible.builtin.shell:
      cmd: systemctl start elasticsearch.service

- name: configurate kibana machine
  hosts: Kibana_group
  become: yes
  vars:
    beats_gpg: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'

  tasks:

  - name: update apt 
    apt:
      update_cache: yes
      upgrade: yes
  - name: install gnupg
    apt:
      name: gnupg
      state: present
  - name: install apt-transport-https
    apt:
      name: apt-transport-https
      state: present
  - name: get GPG
    ansible.builtin.shell:
      cmd: wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/elastic-7.x.gpg --import
  - name: add gpg
    ansible.builtin.shell:
      cmd: sudo chmod 644 /etc/apt/trusted.gpg.d/elastic-7.x.gpg
  - name: Add Beats apt repository.
    ansible.builtin.shell:
      cmd: echo "deb [trusted=yes] https://mirror.yandex.ru/mirrors/elastic/7/ stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
  - name: update apt 
    apt:
      update_cache: yes 
  - name: update apt 
    apt:
      update_cache: yes
      upgrade: yes
  - name: install kibana
    apt:
      name: kibana
      state: present
  - name: update systemd configs
    ansible.builtin.shell:
      cmd: systemctl daemon-reload
  - name: enable unit
    ansible.builtin.shell:
      cmd: systemctl enable kibana.service
  - name: start unit
    ansible.builtin.shell:
      cmd: systemctl start kibana.service
```

---

# Terraform

Config.tpl

```
#cloud-config
users:
  - name: "${VM_USER}"
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - "${SSH_KEY}"
```

vm-autoscale.auto.tfvars

```
folder_id = "b1gkf03i5onh972se4a6"
vm_user   = "admin"
ssh_key   = "<содержимое_публичного_SSH-ключа>"
```

vm-autoscale.tf

```
# Объявление переменных для конфиденциальных параметров

variable "folder_id" {
  type = string
}

variable "vm_user" {
  type = string
}

variable "ssh_key" {
  type      = string
  sensitive = true
}

# Настройка провайдера

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}

# Создание сервисного аккаунта и назначение ему ролей

resource "yandex_iam_service_account" "for-vm" {
  name = "user"
}

resource "yandex_resourcemanager_folder_iam_member" "user" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.for-vm.id}"
}

# Создание облачной сети и подсетей

resource "yandex_vpc_network" "default" {
  name = "edfault"
}

resource "yandex_vpc_subnet" "private-net-a" {
  name           = "private-net-a"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.121.0.0/24"]
  network_id     = yandex_vpc_network.default.id
}

resource "yandex_vpc_subnet" "private-net-b" {
  name           = "private-net-b"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["10.120.0.0/24"]
  network_id     = yandex_vpc_network.default.id
}

resource "yandex_vpc_subnet" "public-net-b" {
  name           = "public-net-b"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["10.122.0.0/24"]
  network_id     = yandex_vpc_network.default.id
}

# Создание группы безопасности

resource "yandex_vpc_security_group" "zbx" {
  name                = "zabbix"
  network_id          = yandex_vpc_network.default.id
  egress {
    protocol          = "ANY"
    description       = "any"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "Any"
    description       = "postgre"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    port              = 5432
  }
  ingress {
    protocol          = "Any"
    description       = "zabbix"
    predefined_target = ["0.0.0.0/0"]
    port              = 10050-10051
  }
  ingress {
    protocol          = "Any"
    predefined_target = ["0.0.0.0/0"]
    port              = 443
  }
  ingress {
    protocol          = "UDP"
    predefined_target = ["0.0.0.0/0"]
    port              = 162
  }
  ingress {
    protocol          = "UDP"
    predefined_target = ["0.0.0.0/0"]
    port              = 53
  }
  ingress {
    protocol          = "UDP"
    predefined_target = ["0.0.0.0/0"]
    port              = 123
  }
}

resource "yandex_vpc_security_group" "slf" {
  name                = "self"
  network_id          = yandex_vpc_network.default.id
  egress {
    protocol          = "ANY"
    description       = "any"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "Any"
    description       = "intern"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "ssh" {
  name                = "ssh"
  network_id          = yandex_vpc_network.default.id
  egress {
    protocol          = "ANY"
    description       = "any"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "Any"
    description       = "for_ssh_traffic"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    port              = 22
  }
}

resource "yandex_vpc_security_group" "kbn" {
  name                = "kibana"
  network_id          = yandex_vpc_network.default.id
  egress {
    protocol          = "ANY"
    description       = "any"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "Any"
    description       = "kibana"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    port              = 5601
  }
}

resource "yandex_vpc_security_group" "http" {
  name                = "http"
  network_id          = yandex_vpc_network.default.id
  egress {
    protocol          = "ANY"
    description       = "any"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "Any"
    description       = "for_http_traffic"
    v4_cidr_blocks    = ["10.120.0.0/24", "10.121.0.0/24", "10.122.0.0/24"]
    port              = 80
  }
}

resource "yandex_vpc_security_group" "wb" {
  name                = "for-web"
  network_id          = yandex_vpc_network.default.id
  egress {
    protocol          = "ANY"
    description       = "any"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "Any"
    description       = "zabbix"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    port              = 10050
  }
  ingress {
    protocol          = "Any"
    description       = "systemd"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    port              = 53
  }
}

resource "yandex_vpc_security_group" "els" {
  name                = "elasticsearch"
  network_id          = yandex_vpc_network.default.id
  egress {
    protocol          = "ANY"
    description       = "any"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "Any"
    description       = "elastic"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    port              = 9200-9210
  }
}

# Создание ВМ

resource "yandex_compute_instance" "web1" {
  name                = "web1"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.user.id
 
  resources {
    memory = 2
    cores  = 2
  }
  
  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  network_interface {
    network_id = yandex_vpc_network.default.id
    subnet_ids = [
      yandex_vpc_subnet.private-net-b.id
    ]
    security_group_ids = [ yandex_vpc_security_group.slf.id, yandex_vpc_security_group.ssh.id, yandex_vpc_security_group.http.id, yandex_vpc_security_group.wb.id ]
  }

  metadata = {
    user-data = templatefile("config.tpl", {
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }

}

resource "yandex_compute_instance" "kibana" {
  name                = "kibana"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.user.id
 
  resources {
    memory = 2
    cores  = 2
  }
  
  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  network_interface {
    network_id = yandex_vpc_network.default.id
    subnet_ids = [
      yandex_vpc_subnet.public-net-b.id
    ]
    security_group_ids = [ yandex_vpc_security_group.slf.id, yandex_vpc_security_group.ssh.id, yandex_vpc_security_group.kbn.id ]
  }

  metadata = {
    user-data = templatefile("config.tpl", {
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }

}

resource "yandex_compute_instance" "zabbix" {
  name                = "zabbix"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.user.id
 
  resources {
    memory = 2
    cores  = 2
  }
  
  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  network_interface {
    network_id = yandex_vpc_network.default.id
    subnet_ids = [
      yandex_vpc_subnet.public-net-b.id
    ]
    security_group_ids = [ yandex_vpc_security_group.slf.id, yandex_vpc_security_group.ssh.id, yandex_vpc_security_group.http.id, yandex_vpc_security_group.zbx.id ]
  }

  metadata = {
    user-data = templatefile("config.tpl", {
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }

}

resource "yandex_compute_instance" "bastion-host" {
  name                = "bastion-host"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.user.id
 
  resources {
    memory = 2
    cores  = 2
  }
  
  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = "fd83omuuv0kssd0g5qt5"
    }
  }

  network_interface {
    network_id = yandex_vpc_network.default.id
    subnet_ids = [
      yandex_vpc_subnet.public-net-b.id
    ]
    security_group_ids = [ yandex_vpc_security_group.slf.id, yandex_vpc_security_group.ssh.id ]
  }

  metadata = {
    user-data = templatefile("config.tpl", {
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }

}

resource "yandex_compute_instance" "elasticsearch" {
  name                = "elasticsearch"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.user.id
 
  resources {
    memory = 2
    cores  = 2
  }
  
  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  network_interface {
    network_id = yandex_vpc_network.default.id
    subnet_ids = [
      yandex_vpc_subnet.private-net-b.id
    ]
    security_group_ids = [ yandex_vpc_security_group.slf.id, yandex_vpc_security_group.ssh.id, yandex_vpc_security_group.els.id ]
  }

  metadata = {
    user-data = templatefile("config.tpl", {
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }

}

resource "yandex_compute_instance" "web2" {
  name                = "web2"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.user.id
 
  resources {
    memory = 2
    cores  = 2
  }
  
  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  network_interface {
    network_id = yandex_vpc_network.default.id
    subnet_ids = [
      yandex_vpc_subnet.private-net-a.id
    ]
    security_group_ids = [ yandex_vpc_security_group.slf.id, yandex_vpc_security_group.ssh.id, yandex_vpc_security_group.http.id, yandex_vpc_security_group.wb.id ]
  }

  metadata = {
    user-data = templatefile("config.tpl", {
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }

}

# Создание целевой группы

resource "yandex_alb_target_group" "web-servers" {
  name           = "web-servers"

  target {
    subnet_id    = "yandex_vpc_subnet.private-net-a.id"
    ip_address   = "10.121.0.30"
  }

  target {
    subnet_id    = "yandex_vpc_subnet.private-net-b.id"
    ip_address   = "10.120.0.17"
  }

}
# Создание группы бэкендов

resource "yandex_alb_backend_group" "frontend" {
  name                     = "frontend"
 
  http_backend {
    name                   = "web1"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["web-servers"]
    load_balancing_config {
      panic_threshold      = 90
    }
    enable_proxy_protocol  = true
  }
}

# Cоздание HTTP роутера

resource "yandex_alb_http_router" "for-web" {
  name          = "for-web"
}

resource "yandex_alb_virtual_host" "main" {
  name                    = "main"
  http_router_id          = yandex_alb_http_router.for-web.id
  route {
    name                  = "way-to-webserv"
    http_route {
      http_route_action {
        backend_group_id  = "yandex_alb_backend_group.frontend"
        timeout           = "60s"
      }
    }
  }
}

# Создание сетевого балансировщика

resource "yandex_lb_network_load_balancer" "balancer" {
  name = "frontend-webs"

  listener {
    name        = "http"
    port        = 80
    target_port = 80
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.autoscale-group.load_balancer[0].target_group_id
    healthcheck {
      name = "tcp"
      tcp_options {
        port = 80
      }
    }
  }
}

# Создать политику

resource "yandex_backup_policy" "daily_backup-life_time_week" {
    compression                       = "NORMAL"
    fast_backup_enabled               = true
    format                            = "AUTO"
    multi_volume_snapshotting_enabled = true
    name                              = "daily_backup-life_time_week"
    performance_window_enabled        = true
    silent_mode_enabled               = true
    splitting_bytes                   = "9223372036854775807"

    reattempts {
        enabled      = true
        interval     = "1m"
        max_attempts = 10
    }

    retention {
        after_backup = false

        rules {
            max_age       = "7d"
            repeat_period = []
        }
    }

    scheduling {
        enabled              = false
        max_parallel_backups = 0
        random_max_delay     = "30m"
        scheme               = "ALWAYS_INCREMENTAL"

        execute_by_interval {
            repeat_at                 = ["04:10"]
            type                      = "DAILY"
        }
    }

    vm_snapshot_reattempts {
        enabled      = true
        interval     = "1m"
        max_attempts = 10
    }
} 
```

---

























































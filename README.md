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

![]()

![]()

3. Страница с информацией о сети:

![]()

4. Страница с информацией об ОЗУ:

![]()

5. Страница с информацией о ЦПУ:

![]()

---

# Логи

Сбор логов осушествляется в 3 этапа:

1. Сбор логов на хостах.
2. Отправка логов на сервер elasticsearch.
3. Обработка логов на сервере elasticsearch.

Далее для визуализации данных сервер Kibana запрашивает и получает данные с сервера elasticsearch. Для визуализации данных необходимо:

1. Создать шаблон считываемых индексов:

![]()

1.1 Под этот шаблон подпадают следующие индексы:

![]()

2. Далее необходимо проанализировать какие поля присутствуют в логах:

![]()

3. На основании полей построить дашборд:

![]()

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

![]()

Хосты web1, web2, elasticsearch не имеют прямого доступа к внешней сети. Все общение происходит через сервера посредники - bastion (NAT gateway) и балансировщик. Для этого бы настроен gateway через bastion host и таблица маршрутизации:

![]()

![]()

Подключение к хостам по ssh происходит через бастион в качестве jump сервера и используется fqdn имена виртуальных машин в зоне:

```
ssh -J bastion@51.250.19.231 admin@web1.ru-central1.internal
```

Схема сети VPC в yandex cloud:

![]()

Подсети VPC в yandex cloud:

![]()

Также были настроены различные группы безопасности предоставляющие доступ только к необходимым портам:

![]()

Подробнее о каждой группе:

1. Elastic

![]()

2. For_web

![]()

3. http

![]()

4. kibana

![]()

5. ssh

![]()

6. zabbix

![]()

---

# Резервное копирование

Резервное копирование производилось встроенным инструментом yandex backup cloud.

Была настроена политика бэкапов:

![]()

В качестве вида бэкапов выбраны инкрементные бэкапы. После этого все виртуальные машины были подкючены к этой политике резервного копирования, после чего был снят первый (полный) бэкап:

![]()

---

# Развертывание серверов и приожений на серверах

Развертывание приложений происходило при помощи terraform и API yandex cloud. Этот файл также лежит в этой ветке.

Развертывание приложений происходило при помощи ansible, который был установлен на bastion host. Этот файл также лежит в этой ветке.

![]()

![]()

![]()

![]()

![]()

---


































































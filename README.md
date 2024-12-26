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
























































































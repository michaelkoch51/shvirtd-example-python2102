Задача 3

![](https://github.com/user-attachments/assets/902194fa-73cc-41ed-98ee-c35a50a7e2a6)

Задача 4

### Код конфигурации инфраструктуры (main.tf)

```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_vpc_network" "final_net" {
  name = "final-network"
}

resource "yandex_vpc_security_group" "final_sg" {
  name       = "final-security-group"
  network_id = yandex_vpc_network.final_net.id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow Nginx web traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8090
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_subnet" "final_sub" {
  name           = "final-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.final_net.id
  v4_cidr_blocks = ["10.130.0.0/24"]
}

resource "yandex_compute_instance" "vm" {
  name        = "netology-docker-host-final"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.final_sub.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.final_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/PoTeyKGPWy5EkMYEnq/udgVK3PbixlHWlLXN7MUtb michaelkochnev@MacBook-Pro-Mihail.local"
  }
}

output "public_ip" {
  value = yandex_compute_instance.vm.network_interface.0.nat_ip_address
}
```
### Задача 5 (*) — Скрипт автоматического резервного копирования бэкапов

**1. Код bash-скрипта (backup.sh):**
```bash
#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
if [ -f "$SCRIPT_DIR/.backup.env" ]; then
    export $(cat "$SCRIPT_DIR/.backup.env" | xargs)
else
    echo "Ошибка: Файл .backup.env не найден!" && exit 1
fi

BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).sql"

# Использование официального образа mysql:8 для полной совместимости с caching_sha2_password
docker run --rm \
  --network shvirtd-example-python2102_backend \
  mysql:8 \
  mysqldump -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" > "$HOME/Desktop/backup/$BACKUP_NAME"

echo "Резервная копия $BACKUP_NAME успешно создана"
```

**2. Настройка Cron-task (crontab -l):**
```text
* * * * * /Users/michaelkochnev/shvirtd-example-python2102/backup.sh > /dev/null 2>&1
```

**3. Безопасность (защита от утечки паролей в Git):**
Переменные авторизации вынесены в скрытый локальный файл конфигурации `.backup.env`, который добавлен в правила `.gitignore`. В публичный репозиторий GitHub конфиг с паролями не попадает.

![](https://github.com/user-attachments/assets/e51caeb2-61aa-47eb-b7d8-1e4172af52b9)

Задача 6

![](https://github.com/user-attachments/assets/b3479008-c2f5-4ba8-be04-6eb3821b1f24)
![](https://github.com/user-attachments/assets/518cd65a-8a51-4b3a-b986-8484caf33277)
![](https://github.com/user-attachments/assets/ef54f49f-87b2-4bee-a6ee-57f6248ce13c)

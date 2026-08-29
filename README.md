

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

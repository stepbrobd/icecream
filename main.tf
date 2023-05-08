terraform {
  cloud {
    organization = "StepBroBD"
    workspaces {
      name = "com-stepbrobd-git"
    }
  }

  required_providers {
    fly = {
      source  = "fly-apps/fly"
      version = "0.0.20"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.5.0"
    }
  }
}

variable "config" {
  type = map(string)
  default = {
    "proejct_name" = "com-stepbrobd-git"

    "public_subdomain"      = "git"
    "public_naked_domain"   = "stepbrobd.com"
    "public_domain_zone_id" = "b344936e258a6bd57c5e00af70fe0326"
    "public_port"           = "22"

    "cpu_count" = "1"      # at least 1
    "cpu_type"  = "shared" # shared, standard, performance
    "ram_size"  = "512"    # MB
    "disk_size" = "10"     # GB
    "region"    = "bos"    # https://fly.io/docs/reference/regions

    "name"          = "StepBroBD"
    "image"         = "charmcli/soft-serve:v0.5.2"
    "admin_ssh_key" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ47Qtg6qSenUh6Whg3ZIpIhdZZdqdG+L1z2f9UnB+Mw"
  }
}

provider "fly" {
  fly_http_endpoint = "api.machines.dev"
}

resource "fly_app" "app" {
  name = var.config["proejct_name"]
}

resource "fly_volume" "volume" {
  app        = var.config["proejct_name"]
  name       = replace(format("%s-volume", var.config["proejct_name"]), "-", "_")
  region     = var.config["region"]
  size       = tonumber(var.config["disk_size"])
  depends_on = [fly_app.app]
}

resource "fly_ip" "ipv4" {
  app        = var.config["proejct_name"]
  type       = "v4"
  depends_on = [fly_app.app]
}

resource "fly_ip" "ipv6" {
  app        = fly_app.app.name
  type       = "v6"
  depends_on = [fly_app.app]
}

resource "fly_machine" "machine" {
  app    = var.config["proejct_name"]
  name   = replace(format("%s-machine", var.config["proejct_name"]), "-", "_")
  region = var.config["region"]
  image  = var.config["image"]

  cpus     = tonumber(var.config["cpu_count"])
  cputype  = var.config["cpu_type"]
  memorymb = tonumber(var.config["ram_size"])

  env = {
    "SOFT_SERVE_NAME"               = var.config["name"]
    "SOFT_SERVE_INITIAL_ADMIN_KEYS" = var.config["admin_ssh_key"]
    "SOFT_SERVE_DATA_PATH"          = "/data"

    "SOFT_SERVE_SSH_LISTEN_ADDR" = ":22"
    "SOFT_SERVE_SSH_PUBLIC_URL"  = format("ssh://%s.%s", var.config["public_subdomain"], var.config["public_naked_domain"])

    "SOFT_SERVE_HTTP_LISTEN_ADDR" = ":443"
    "SOFT_SERVE_HTTP_PUBLIC_URL"  = format("https://%s.%s", var.config["public_subdomain"], var.config["public_naked_domain"])
  }

  mounts = [{
    encrypted = true
    path      = "/data"
    volume    = fly_volume.volume.name
  }]

  services = [{
    internal_port = 23231
    protocol      = "tcp"
    ports         = [{ port = tonumber(var.config["public_port"]) }]
  }]

  depends_on = [fly_app.app, fly_volume.volume]
}

provider "cloudflare" {}

resource "cloudflare_record" "a" {
  zone_id         = var.config["public_domain_zone_id"]
  type            = "A"
  name            = var.config["public_subdomain"]
  value           = fly_ip.ipv4.address
  ttl             = 1
  proxied         = false
  allow_overwrite = false
  depends_on      = [fly_ip.ipv4]
}

resource "cloudflare_record" "aaaa" {
  zone_id         = var.config["public_domain_zone_id"]
  type            = "AAAA"
  name            = var.config["public_subdomain"]
  value           = fly_ip.ipv6.address
  ttl             = 1
  proxied         = false
  allow_overwrite = false
  depends_on      = [fly_ip.ipv6]
}

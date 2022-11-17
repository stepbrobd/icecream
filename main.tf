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
      version = "3.27.0"
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

    "admin_ssh_key" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVktHp6yjTknysVbU24K014tFKCIIM3/rWqZV591NRn"

    "region"    = "sjc"    # https://fly.io/docs/reference/regions
    "cpu_count" = "1"      # at least 1
    "cpu_type"  = "shared" # shared, standard, performance
    "ram_size"  = "512"    # MB
    "disk_size" = "5"      # GB
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
  image  = "charmcli/soft-serve:v0.4.3"

  cpus     = tonumber(var.config["cpu_count"])
  cputype  = var.config["cpu_type"]
  memorymb = tonumber(var.config["ram_size"])

  env = {
    "SOFT_SERVE_BIND_ADDRESS"      = "0.0.0.0"
    "SOFT_SERVE_HOST"              = format("%s.%s", var.config["public_subdomain"], var.config["public_naked_domain"])
    "SOFT_SERVE_PORT"              = "23231"
    "SOFT_SERVE_INITIAL_ADMIN_KEY" = var.config["admin_ssh_key"]
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

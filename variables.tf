variable "digitalocean_token" {
    description = "DigitalOcean API token"
    type = string
}

variable "cloudflare_api_token" {
    description = "Cloudflare API token"
    type = string
}

variable "cloudflare_zone_id" {
    description = "Cloudflare zone ID"
    type = string
}

variable "domain" {
    description = "The domain of the Trojan server"
    type = string
}

variable "password" {
    description = "The password of the Trojan server"
    type = string
}

variable "region" {
    description = "The region where the Droplet will be created"
    type = string
}

variable "droplet_size" {
    description = "The size of the Droplet"
    type = string
    default = "s-1vcpu-512mb-10gb"
}

variable "droplet_image" {
    description = "The image of the Droplet"
    type = string
    default = "ubuntu-23-10-x64"
}

variable "droplet_name" {
    description = "The name of the Droplet"
    type = string
    default = "trojan"
}

variable "ssh_key_fingerprint" {
    description = "The fingerprint of the SSH key"
    type = string
    default = "a7:35:90:26:29:b0:0c:8c:28:9c:17:13:47:b2:42:ce"
}

variable "ssh_private_key" {
    description = "The private key of the SSH key"
    type = string
    default = "~/.ssh/id_rsa"
}




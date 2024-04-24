terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.5"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "digitalocean_droplet" "server" {
  image = var.droplet_image
  name = "${var.droplet_name}-${var.region}"
  region = var.region
  size = var.droplet_size
  ssh_keys = ["${var.ssh_key_fingerprint}"]
  ipv6 = true

  # 连接到服务器
  connection {
    type = "ssh"
    user = "root"
    private_key = file(var.ssh_private_key)
    host = self.ipv4_address
  }

  # 初始化服务器，创建目录，安装软件
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/trojan-go",
      "apt-get install jq nginx -y"
    ] 
  }

  # 伪装首页
  provisioner "file" {
    source = "index.html"
    destination = "/var/www/html/index.html"
  }

  # 安装 Certbot，申请证书
  provisioner "remote-exec" {
    inline = [
      # 安装 Certbot
      "snap install --classic certbot && ln -s /snap/bin/certbot /usr/bin/certbot",
      "snap set certbot trust-plugin-with-root=ok",
      "snap install certbot-dns-cloudflare",
      # 配置 Cloudflare API Token
      "mkdir -p ~/.secrets/certbot",
      "echo 'dns_cloudflare_api_token = ${var.cloudflare_api_token}' > ~/.secrets/certbot/cloudflare.ini",
      "chmod 600 ~/.secrets/certbot/cloudflare.ini",
      # 申请证书
      "certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini -d ${var.domain} --dns-cloudflare-propagation-seconds 60 --agree-tos --register-unsafely-without-email --no-eff-email --force-renewal",
    ] 
  }

  # 打包上传 Trojan 安装包
  provisioner "local-exec" {
    command = "tar -zcvf trojan.tar.gz trojan"
  }

  provisioner "file" {
    source = "trojan.tar.gz"
    destination = "/usr/local/trojan.tar.gz"
  }

  # 安装 Trojan
  provisioner "remote-exec" {
    inline = [
      "cd /usr/local && tar -zxvf trojan.tar.gz",
      "cp /usr/local/trojan/trojan-go.service /usr/lib/systemd/system/trojan-go.service",
      "chmod +x /usr/local/trojan/trojan-go",
      # 更新 Trojan 配置文件
      "jq '.password[0] = \"${var.password}\" | .ssl.sni = \"${var.domain}\" | .websocket.host = \"${var.domain}\" | .ssl.cert = \"/etc/letsencrypt/live/${var.domain}/fullchain.pem\" | .ssl.key = \"/etc/letsencrypt/live/${var.domain}/privkey.pem\"' /usr/local/trojan/config.template > /usr/local/trojan/config.json",
    ]
  }

  # 启动 Trojan
  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl enable trojan-go",
      "systemctl start trojan-go"
    ]
  }
}

# 更新 DNS 记录
resource "cloudflare_record" "server" {
  zone_id = var.cloudflare_zone_id
  name = split(".", var.domain)[0]
  value = digitalocean_droplet.server.ipv4_address
  type = "A"
  ttl = 3600
  allow_overwrite = true
  proxied = false

  depends_on = [digitalocean_droplet.server]
}

output "ip_address" {
  value = digitalocean_droplet.server.ipv4_address
  description = "The public IP address of the Trojan server"
}

output "password" {
  value = var.password
  description = "The password of the Trojan server"
}

output "domain" {
  value = var.domain
  description = "The domain of the Trojan server"
}
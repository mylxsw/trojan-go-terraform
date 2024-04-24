# Trojan-Go 一键部署

该项目用于一键部署 Trojan-Go 到 Digital Ocean Droplet，并使用 Cloudflare 自动配置域名解析，Let's Encrypt 自动生成证书。

## 环境准备

- [Terraform](https://www.terraform.io/downloads.html)

## 使用说明

1. 创建 SSH 私钥+公钥（对应配置项 `ssh_private_key`），在 [Digital Ocean](https://cloud.digitalocean.com) 上添加公钥，获取到公钥的指纹（对应配置项 `ssh_key_fingerprint`）
2. 在 Digital Ocean 中创建 [API Token](https://cloud.digitalocean.com/account/api/tokens) （对应配置项 `digitalocean_token`）
3. 在 [Cloudflare](https://www.cloudflare.com) 中获取域名的 ZoneID（对应配置项 `cloudflare_zone_id`）
4. 在 Cloudflare 中创建 [API Token](https://dash.cloudflare.com/profile/api-tokens)，权限分配 `Zone/DNS/Edit` （对应配置项 `cloudflare_api_token`）

## 配置参数

- `digitalocean_token`：Digital Ocean API Token
- `cloudflare_api_token`：Cloudflare API Token
- `cloudflare_zone_id`：Cloudflare Zone ID
- `ssh_key_fingerprint`：SSH 公钥指纹
- `ssh_private_key`：SSH 私钥路径
- `domain`：域名
- `password`：Trojan-Go 密码
- `region`：服务器部署区域
- `droplet_size`：服务器规格
- `droplet_image`：服务器镜像名称

### Region

- `sgp1` Singapore
- `sfo1/2/3` San Francisco
- `nyc1/2/3` New York
- `ams2/3` Amsterdam
- `lon1` London
- `fra1` Frankfurt
- `tor1` Toronto
- `blr1` Bangalore
- `syd1` Sydney

### Size

- s-1vcpu-512mb-10gb
- s-1vcpu-1gb
- s-1vcpu-2gb
- s-2vcpu-2gb
- s-2vcpu-4gb
- s-1vcpu-1gb-35gb-intel
- s-1vcpu-1gb-amd


## 示例

在 San Francisco 创建一个实例

```bash
export DIGITALOCEAN_ACCESS_TOKEN=Digital Ocean API Token
export CLOUDFLARE_API_TOKEN=Cloudflare API Token
export CLOUDFLARE_ZONE_ID=Cloudflare Zone ID

terraform apply -var digitalocean_token=$DIGITALOCEAN_ACCESS_TOKEN \
    -var cloudflare_api_token=$CLOUDFLARE_API_TOKEN \
    -var cloudflare_zone_id=$CLOUDFLARE_ZONE_ID \
    -var ssh_key_fingerprint=a7:35:90:26:29:b0:0c:8c:28:9c:17:13:47:b2:42:ce \
    -var ssh_private_key=~/.ssh/id_rsa \
    -var domain=hello-us.example.com \
    -var password=fre4-0edv-7cQ \
    -var region=sfo3
```

> 注意：一定要修改 domain 和 password！

客户端配置示例

Surge：

```
DigitalOcean = trojan, hello-us.example.com, 443, password=fre4-0edv-7cQ, skip-cert-verify=true, sni=hello-us.example.com
```

Clash：

```json
{
    "name": "DigitalOcean",
    "password": "fre4-0edv-7cQ",
    "port": 443,
    "server": "hello-us.example.com",
    "skip-cert-verify": true,
    "sni": "hello-us.example.com",
    "type": "trojan"
}
```
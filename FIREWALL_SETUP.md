# 防火墙配置指南

部署后需要开放端口才能从外网访问。

## 🔥 开放端口（必须）

### 方法 1：使用 UFW（Ubuntu 默认）

```bash
# 1. 检查防火墙状态
sudo ufw status

# 2. 开放 8888 端口
sudo ufw allow 8888/tcp

# 3. 重新加载防火墙
sudo ufw reload

# 4. 验证端口已开放
sudo ufw status | grep 8888
```

### 方法 2：使用 iptables

```bash
# 检查现有规则
sudo iptables -L -n | grep 8888

# 开放 8888 端口
sudo iptables -I INPUT -p tcp --dport 8888 -j ACCEPT

# 保存规则（Ubuntu/Debian）
sudo iptables-save > /etc/iptables/rules.v4

# 或者（CentOS/RHEL）
sudo service iptables save
```

### 方法 3：云服务商防火墙

#### DigitalOcean
1. 登录 DigitalOcean 控制台
2. 进入 **Networking → Firewalls**
3. 选择你的 Droplet 关联的防火墙
4. 添加 **Inbound Rules**：
   - Type: `Custom`
   - Protocol: `TCP`
   - Port Range: `8888`
   - Sources: `All IPv4` 和 `All IPv6`
5. 保存

#### AWS (EC2)
1. 进入 **EC2 Console → Security Groups**
2. 选择实例的安全组
3. 添加 **Inbound Rule**：
   - Type: `Custom TCP`
   - Port: `8888`
   - Source: `0.0.0.0/0` (所有IP) 或 `::/0` (IPv6)

#### 阿里云/腾讯云
1. 进入**安全组规则**
2. 添加入站规则：
   - 协议: `TCP`
   - 端口: `8888`
   - 授权对象: `0.0.0.0/0`

## ✅ 验证配置

```bash
# 1. 本地测试
curl -I http://localhost:8888

# 2. 远程测试（从另一台机器）
curl -I http://YOUR_SERVER_IP:8888

# 3. 检查端口监听
netstat -tlnp | grep 8888
# 或
ss -tlnp | grep 8888
```

## 🔒 安全建议

### 限制访问（可选）

如果只想允许特定 IP 访问：

```bash
# UFW 限制访问
sudo ufw allow from YOUR_IP to any port 8888

# iptables 限制访问
sudo iptables -A INPUT -p tcp -s YOUR_IP --dport 8888 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8888 -j DROP
```

### 添加密码保护（可选）

```bash
# 1. 安装 htpasswd
sudo apt-get install apache2-utils -y

# 2. 创建密码文件
sudo htpasswd -c /etc/nginx/.htpasswd training_user

# 3. 在 Nginx 配置中添加认证
sudo nano /etc/nginx/sites-available/ai-coding-training

# 在 server 块中添加：
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

# 4. 重载 Nginx
sudo nginx -t
sudo systemctl reload nginx
```

## 🐛 常见问题

**Q: 开放端口后还是无法访问？**

检查：
1. 云服务商的防火墙/安全组是否配置
2. 服务器本地防火墙是否开放
3. Nginx 是否正常运行：`systemctl status nginx`
4. 端口是否真的在监听：`netstat -tlnp | grep 8888`

**Q: 如何关闭端口？**

```bash
# UFW
sudo ufw delete allow 8888/tcp

# iptables
sudo iptables -D INPUT -p tcp --dport 8888 -j ACCEPT
```

**Q: 如何查看所有开放的端口？**

```bash
sudo ufw status numbered
# 或
sudo iptables -L -n
```

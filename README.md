# AI Coding 内部培训页面

异乡好居管理干部 AI Coding 培训材料

## 🎯 项目简介

这是一个交互式的 AI Coding 培训页面，展示了：
- 18 个真实 GitHub 项目
- 4 大核心案例深度讲解
- 交互式代码演示
- 完整的避坑指南
- ⚡ **新增**: AnyGen AI 工作台推荐

**技术栈**: 纯静态 HTML + Tailwind CSS + JavaScript

**线上地址**: https://training.pylosy.com

## 🚀 快速开始

### 本地预览

```bash
# 克隆项目
git clone https://github.com/yalding8/ai-coding-training.git
cd ai-coding-training

# 方法 1: 直接打开
open index.html

# 方法 2: 本地服务器（推荐）
python3 -m http.server 8000
# 访问 http://localhost:8000
```

## 📦 部署到服务器

### 智能部署脚本（推荐）

使用增强版 `deploy-smart.sh` 脚本，支持多种部署方式：

```bash
# 添加 SSH Key 到 agent（避免重复输入密码）
ssh-add ~/.ssh/id_ed25519

# 运行智能部署
chmod +x deploy-smart.sh
./deploy-smart.sh root@YOUR_SERVER_IP
```

**部署选项**：
1. **端口 8080** - 独立端口部署（推荐用于测试）
2. **子路径 /training** - 与现有服务共存
3. **覆盖端口 80** - 完全接管 80 端口（慎用）
4. **域名部署** - 使用自定义域名（支持自定义端口，如 8888）

### 自动化功能

- ✅ 自动检测服务器连接
- ✅ 自动检测端口占用
- ✅ 强制同步代码（解决 Git 冲突）
- ✅ 支持自定义 Nginx 监听端口
- ✅ 自动配置 SSL 证书（certbot）

### 选项 2: 手动部署

```bash
# 1. SSH 到服务器
ssh root@YOUR_SERVER_IP

# 2. 克隆代码
cd /var/www
git clone https://github.com/yalding8/ai-coding-training.git

# 3. 配置 Nginx
sudo nano /etc/nginx/sites-available/ai-coding-training
# 粘贴配置（见下方）

# 4. 启用站点
sudo ln -s /etc/nginx/sites-available/ai-coding-training /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Nginx 配置示例

```nginx
server {
    listen 80;
    server_name training.yourdomain.com;  # 或使用 IP

    root /var/www/ai-coding-training;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Gzip 压缩
    gzip on;
    gzip_types text/plain text/css text/javascript application/javascript;
}
```

### 选项 3: 使用子路径部署（如果端口 80 被占用）

如果服务器上已有其他网站运行，可以将培训页面部署到子路径：

```nginx
# 添加到现有 Nginx 配置中
location /training {
    alias /var/www/ai-coding-training;
    index index.html;
    try_files $uri $uri/ /training/index.html;
}
```

访问地址: http://YOUR_SERVER_IP/training

## 🌐 绑定域名（可选）

### 1. DNS 配置

在你的域名服务商添加 A 记录：

```
training.yourdomain.com  →  YOUR_SERVER_IP
```

### 2. 更新 Nginx 配置

```bash
ssh root@YOUR_SERVER_IP
sudo nano /etc/nginx/sites-available/ai-coding-training
# 修改 server_name 为你的域名
sudo systemctl reload nginx
```

### 3. 配置 SSL（推荐）

**自动配置（推荐）**：
```bash
ssh root@YOUR_SERVER_IP
certbot --nginx -d training.yourdomain.com --non-interactive --agree-tos --register-unsafely-without-email --redirect
```

**注意事项**：
- 如果使用 Cloudflare CDN，建议将 SSL/TLS 模式设置为 **Full** 或 **Full (Strict)**
- 如果遇到 `ERR_TOO_MANY_REDIRECTS` 错误，需要移除 Nginx 80 端口的强制 HTTPS 重定向
- 推荐配置：同时监听 80 和 443，不强制跳转（兼容 Cloudflare Flexible 模式）

## 📝 更新内容

当你修改了代码后：

```bash
# 本地提交并推送
git add .
git commit -m "更新内容"
git push origin main

# 服务器更新
ssh root@YOUR_SERVER_IP "cd /var/www/ai-coding-training && git pull"
```

或直接运行部署脚本：
```bash
./deploy.sh
```

## 📂 项目结构

```
ai-coding-training/
├── index.html          # 主页面（含 AnyGen 推荐）
├── deploy.sh           # 基础部署脚本
├── deploy-smart.sh     # 智能部署脚本（推荐）
├── fix-502.sh          # 502 错误修复脚本
├── FIREWALL_SETUP.md   # 防火墙配置说明
└── README.md           # 说明文档
```

## 🎨 特性

- ✨ 深色代码美学设计
- 📱 完全响应式（支持移动端）
- ⚡ 平滑滚动动画
- 🔗 真实 GitHub 项目链接
- 💻 可展开的代码块
- 🎯 交互式导航
- ⚡ **新增**: AnyGen AI 工作台特别推荐

## 📊 包含的项目案例

1. **salary-calculator** - 薪资计算器（JavaScript）
2. **ai-news-bot** - AI 新闻机器人（Python）
3. **market-scanner** - 市场扫描器（HTML）
4. **aitest** - AI 能力测试系统（Python） ⭐ 公开
5. **ai-podcast** - 播客自动化系统（Python）
6. **uhomespay** - 支付系统（JavaScript + Vue）
7. 更多 12 个项目...

## 🔧 常见问题

**Q: 访问不了怎么办？**
- 检查服务器防火墙是否开放 80/443 端口
- 检查 Nginx 是否正常运行：`systemctl status nginx`
- 查看 Nginx 错误日志：`tail -f /var/log/nginx/error.log`

**Q: 遇到 ERR_TOO_MANY_REDIRECTS 怎么办？**
- 检查 Cloudflare SSL/TLS 模式（推荐使用 Full）
- 确认 Nginx 配置同时监听 80 和 443，且不强制重定向
- 清除浏览器缓存或使用隐身模式

**Q: 如何修改端口？**
- 使用 `deploy-smart.sh` 选项 4，可自定义监听端口
- 或手动编辑 Nginx 配置，修改 `listen 80;` 为其他端口

**Q: 部署时一直要求输入 SSH 密码？**
```bash
# 将 SSH Key 添加到 agent
ssh-add ~/.ssh/id_ed25519
```

**Q: 如何添加访问密码？**
```bash
# 创建密码文件
sudo apt-get install apache2-utils
sudo htpasswd -c /etc/nginx/.htpasswd training_user

# 在 Nginx 配置中添加
auth_basic "Restricted Access";
auth_basic_user_file /etc/nginx/.htpasswd;
```

## 📞 联系方式

- **GitHub**: [@yalding8](https://github.com/yalding8)
- **项目地址**: https://github.com/yalding8/ai-coding-training

## 📄 许可证

Copyright © 2026 异乡好居 Uhomes

#!/bin/bash

# AI Coding Training 部署脚本

# 配置服务器地址（修改为你的服务器）
SERVER="${DEPLOY_SERVER:-root@YOUR_SERVER_IP}"
REPO_URL="https://github.com/yalding8/ai-coding-training.git"
DEPLOY_PATH="/var/www/ai-coding-training"
NGINX_AVAILABLE="/etc/nginx/sites-available/ai-coding-training"
NGINX_ENABLED="/etc/nginx/sites-enabled/ai-coding-training"

# 使用方法：
# 1. 直接修改上面的 SERVER 变量
# 2. 或者设置环境变量：export DEPLOY_SERVER="root@your-server-ip"
# 3. 或者作为参数传递：./deploy.sh root@your-server-ip

if [ -n "$1" ]; then
    SERVER="$1"
fi

echo "🚀 开始部署 AI Coding Training..."

# 1. 在服务器上克隆/更新代码
echo "📦 步骤 1: 部署代码到服务器..."
ssh $SERVER << 'ENDSSH'
    # 创建部署目录
    if [ ! -d "/var/www/ai-coding-training" ]; then
        echo "克隆仓库..."
        cd /var/www
        git clone https://github.com/yalding8/ai-coding-training.git
    else
        echo "更新代码..."
        cd /var/www/ai-coding-training
        git pull origin main
    fi

    echo "✅ 代码部署完成"
ENDSSH

# 2. 配置 Nginx
echo "🔧 步骤 2: 配置 Nginx..."
ssh $SERVER << 'ENDSSH'
    # 创建 Nginx 配置文件
    cat > /etc/nginx/sites-available/ai-coding-training << 'EOF'
server {
    listen 80;
    server_name _;  # 监听所有域名，也可以改为具体域名

    root /var/www/ai-coding-training;
    index index.html;

    # 日志
    access_log /var/log/nginx/ai-coding-training.access.log;
    error_log /var/log/nginx/ai-coding-training.error.log;

    # 主页面
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 缓存静态文件
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf)$ {
        expires 7d;
        add_header Cache-Control "public, immutable";
    }

    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    gzip_min_length 1000;
}
EOF

    # 启用站点
    if [ ! -L "/etc/nginx/sites-enabled/ai-coding-training" ]; then
        ln -s /etc/nginx/sites-available/ai-coding-training /etc/nginx/sites-enabled/
    fi

    # 测试 Nginx 配置
    nginx -t

    # 重启 Nginx
    systemctl reload nginx

    echo "✅ Nginx 配置完成"
ENDSSH

# 3. 检查部署状态
echo "🔍 步骤 3: 检查部署状态..."
ssh $SERVER << 'ENDSSH'
    echo "📂 部署目录:"
    ls -lh /var/www/ai-coding-training/

    echo ""
    echo "🌐 Nginx 状态:"
    systemctl status nginx --no-pager | head -10
ENDSSH

echo ""
echo "✅ 部署完成！"
echo ""
echo "🌐 访问地址："
echo "   http://${SERVER#*@}  (根据实际端口配置访问)"
echo ""
echo "📝 提示："
echo "   - 如果要绑定域名，修改 Nginx 配置中的 server_name"
echo "   - 日志位置: /var/log/nginx/ai-coding-training.*.log"
echo "   - 代码位置: /var/www/ai-coding-training"
echo "   - 开放防火墙端口: 参考 FIREWALL_SETUP.md"
echo ""

#!/bin/bash

# AI Coding Training 智能部署脚本
# 自动检测服务器配置并选择最佳部署方式

# 配置服务器地址（修改为你的服务器）
SERVER="${DEPLOY_SERVER:-root@YOUR_SERVER_IP}"
REPO_URL="https://github.com/yalding8/ai-coding-training.git"

# 使用方法：
# 1. 直接修改上面的 SERVER 变量
# 2. 或者设置环境变量：export DEPLOY_SERVER="root@your-server-ip"
# 3. 或者作为参数传递：./deploy-smart.sh root@your-server-ip

if [ -n "$1" ]; then
    SERVER="$1"
    echo "📝 使用参数指定的服务器: $SERVER"
fi

echo "🚀 AI Coding Training 智能部署"
echo "================================"
echo ""

# 检查服务器连接
echo "🔍 检查服务器连接..."
if ! ssh -o ConnectTimeout=5 $SERVER "echo '连接成功'" > /dev/null 2>&1; then
    echo "❌ 无法连接到服务器 $SERVER"
    echo "请检查："
    echo "  1. 服务器是否运行"
    echo "  2. SSH 密钥是否配置"
    echo "  3. 网络连接是否正常"
    exit 1
fi
echo "✅ 服务器连接正常"
echo ""

# 检查端口 80 占用情况
echo "🔍 检查端口占用情况..."
PORT_80_STATUS=$(ssh $SERVER "lsof -i :80 2>/dev/null | grep LISTEN | wc -l")

if [ "$PORT_80_STATUS" -gt 0 ]; then
    echo "⚠️  端口 80 已被占用（可能是 aitest 或其他项目）"
    echo ""
    echo "请选择部署方式："
    echo "  1) 使用端口 8080（推荐）"
    echo "  2) 使用子路径 /training"
    echo "  3) 覆盖端口 80（不推荐，会影响现有服务）"
    echo "  4) 使用域名 training.pylosy.com (虚拟主机)"
    echo ""
    read -p "请选择 [1-4]: " DEPLOY_OPTION
else
    echo "✅ 端口 80 可用"
    DEPLOY_OPTION="1"
fi

echo ""
echo "📦 开始部署..."

# 部署代码
ssh $SERVER << 'ENDSSH'
    if [ ! -d "/var/www/ai-coding-training" ]; then
        echo "📥 克隆仓库..."
        cd /var/www
        git clone https://github.com/yalding8/ai-coding-training.git
    else
        echo "🔄 更新代码..."
        cd /var/www/ai-coding-training
        # 强制重置以避免本地修改导致的冲突
        git fetch origin
        git reset --hard origin/main
    fi
ENDSSH

# 根据选择配置 Nginx
case $DEPLOY_OPTION in
    1)
        echo "🔧 配置 Nginx（端口 8080）..."
        ssh $SERVER << 'ENDSSH'
            cat > /etc/nginx/sites-available/ai-coding-training << 'EOF'
server {
    listen 8080;
    server_name _;

    root /var/www/ai-coding-training;
    index index.html;

    access_log /var/log/nginx/ai-coding-training.access.log;
    error_log /var/log/nginx/ai-coding-training.error.log;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf)$ {
        expires 7d;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF
            # 启用站点
            ln -sf /etc/nginx/sites-available/ai-coding-training /etc/nginx/sites-enabled/
            nginx -t && systemctl reload nginx
ENDSSH
        ACCESS_URL="http://${SERVER#*@}:8080"
        ;;

    2)
        echo "🔧 配置 Nginx（子路径 /training）..."
        ssh $SERVER << 'ENDSSH'
            # 添加到默认配置
            NGINX_CONF="/etc/nginx/sites-available/default"

            # 检查是否已有 /training 配置
            if ! grep -q "location /training" "$NGINX_CONF"; then
                # 在 server 块中添加配置
                sed -i '/server {/a \    # AI Coding Training\n    location /training {\n        alias /var/www/ai-coding-training;\n        index index.html;\n        try_files $uri $uri/ /training/index.html;\n    }\n' "$NGINX_CONF"
                nginx -t && systemctl reload nginx
                echo "✅ 已添加 /training 路径配置"
            else
                echo "ℹ️  /training 配置已存在，跳过"
            fi
ENDSSH
        ACCESS_URL="http://${SERVER#*@}/training"
        ;;
    
    4)
        read -p "请输入 Nginx 监听端口 [默认 80]: " NGINX_PORT
        NGINX_PORT=${NGINX_PORT:-80}
        echo "🔧 配置 Nginx（域名 training.pylosy.com，端口 $NGINX_PORT + SSL）..."
        
        ssh $SERVER << ENDSSH
            # 检查 SSL 证书是否存在
            if [ -d "/etc/letsencrypt/live/training.pylosy.com" ]; then
                echo "✅ 检测到 SSL 证书，配置 HTTPS..."
                cat > /etc/nginx/sites-available/ai-coding-training << EOF
server {
    listen $NGINX_PORT;
    listen 443 ssl;
    server_name training.pylosy.com;

    root /var/www/ai-coding-training;
    index index.html;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/training.pylosy.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/training.pylosy.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    access_log /var/log/nginx/ai-coding-training.access.log;
    error_log /var/log/nginx/ai-coding-training.error.log;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    gzip on;
    gzip_types text/plain text/css text/javascript application/javascript;
}
EOF
            else
                echo "⚠️  未检测到 SSL 证书，仅配置 HTTP..."
                cat > /etc/nginx/sites-available/ai-coding-training << EOF
server {
    listen $NGINX_PORT;
    server_name training.pylosy.com;

    root /var/www/ai-coding-training;
    index index.html;

    access_log /var/log/nginx/ai-coding-training.access.log;
    error_log /var/log/nginx/ai-coding-training.error.log;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    gzip on;
    gzip_types text/plain text/css text/javascript application/javascript;
}
EOF
            fi
            ln -sf /etc/nginx/sites-available/ai-coding-training /etc/nginx/sites-enabled/
            nginx -t && systemctl reload nginx
ENDSSH
        if [ "$NGINX_PORT" = "80" ]; then
            ACCESS_URL="https://training.pylosy.com"
        else
            ACCESS_URL="http://training.pylosy.com:$NGINX_PORT"
        fi
        ;;

    3)
        echo "🔧 配置 Nginx（端口 80）..."
        echo "⚠️  警告：这可能会影响现有服务！"
        read -p "确认继续？[y/N]: " CONFIRM
        if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
            echo "❌ 部署已取消"
            exit 1
        fi

        ssh $SERVER << 'ENDSSH'
            cat > /etc/nginx/sites-available/ai-coding-training << 'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/ai-coding-training;
    index index.html;

    access_log /var/log/nginx/ai-coding-training.access.log;
    error_log /var/log/nginx/ai-coding-training.error.log;

    location / {
        try_files $uri $uri/ /index.html;
    }

    gzip on;
    gzip_types text/plain text/css text/javascript application/javascript;
}
EOF
            ln -sf /etc/nginx/sites-available/ai-coding-training /etc/nginx/sites-enabled/
            nginx -t && systemctl reload nginx
ENDSSH
        ACCESS_URL="http://${SERVER#*@}"
        ;;
esac

echo ""
echo "✅ 部署完成！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 访问地址："
echo "   $ACCESS_URL"
echo ""
echo "📂 服务器路径："
echo "   /var/www/ai-coding-training"
echo ""
echo "📝 日志文件："
echo "   /var/log/nginx/ai-coding-training.access.log"
echo "   /var/log/nginx/ai-coding-training.error.log"
echo ""
echo "🔧 常用命令："
echo "   更新代码: ssh $SERVER 'cd /var/www/ai-coding-training && git pull'"
echo "   查看日志: ssh $SERVER 'tail -f /var/log/nginx/ai-coding-training.access.log'"
echo "   重启Nginx: ssh $SERVER 'systemctl reload nginx'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

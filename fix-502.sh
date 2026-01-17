#!/bin/bash

# 修复 502 错误的诊断和修复脚本

echo "🔍 诊断 502 Bad Gateway 错误..."
echo ""

# 1. 检查 Nginx 配置
echo "1️⃣ 检查 Nginx 配置语法..."
nginx -t
if [ $? -ne 0 ]; then
    echo "❌ Nginx 配置有语法错误！"
    exit 1
fi
echo "✅ Nginx 配置语法正确"
echo ""

# 2. 检查项目目录
echo "2️⃣ 检查项目目录..."
if [ ! -d "/var/www/ai-coding-training" ]; then
    echo "❌ 项目目录不存在！"
    echo "正在克隆项目..."
    cd /var/www
    git clone https://github.com/yalding8/ai-coding-training.git
else
    echo "✅ 项目目录存在"
    ls -lh /var/www/ai-coding-training/index.html
fi
echo ""

# 3. 检查文件权限
echo "3️⃣ 检查文件权限..."
chmod -R 755 /var/www/ai-coding-training
chown -R www-data:www-data /var/www/ai-coding-training
echo "✅ 文件权限已修复"
echo ""

# 4. 检查当前 Nginx 配置
echo "4️⃣ 当前 Nginx 配置..."
if grep -q "location /training" /etc/nginx/sites-available/default; then
    echo "✅ 找到 /training 配置"
    grep -A 5 "location /training" /etc/nginx/sites-available/default
else
    echo "❌ 未找到 /training 配置"
    echo ""
    echo "📝 正在添加正确的配置..."

    # 备份原配置
    cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup.$(date +%Y%m%d_%H%M%S)

    # 查找 server 块并添加配置
    # 先删除可能存在的旧配置
    sed -i '/# AI Coding Training/,/^[[:space:]]*}/d' /etc/nginx/sites-available/default

    # 在第一个 server 块中添加配置
    awk '/server[[:space:]]*\{/ && !found {
        print $0
        print "    # AI Coding Training"
        print "    location /training {"
        print "        alias /var/www/ai-coding-training;"
        print "        index index.html;"
        print "        try_files $uri $uri/ /training/index.html;"
        print "    }"
        print ""
        found=1
        next
    }
    {print}' /etc/nginx/sites-available/default > /tmp/nginx_default_new

    mv /tmp/nginx_default_new /etc/nginx/sites-available/default

    echo "✅ 配置已添加"
fi
echo ""

# 5. 测试新配置
echo "5️⃣ 测试新配置..."
nginx -t
if [ $? -eq 0 ]; then
    echo "✅ 配置测试通过"

    # 重载 Nginx
    echo ""
    echo "6️⃣ 重载 Nginx..."
    systemctl reload nginx

    if [ $? -eq 0 ]; then
        echo "✅ Nginx 重载成功"
    else
        echo "❌ Nginx 重载失败，尝试重启..."
        systemctl restart nginx
    fi
else
    echo "❌ 配置测试失败！"
    echo "恢复备份配置..."
    cp /etc/nginx/sites-available/default.backup.* /etc/nginx/sites-available/default
    systemctl reload nginx
    exit 1
fi
echo ""

# 7. 检查 Nginx 状态
echo "7️⃣ 检查 Nginx 状态..."
systemctl status nginx --no-pager | head -15
echo ""

# 8. 测试访问
echo "8️⃣ 测试本地访问..."
curl -I http://localhost/training 2>&1 | head -10
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 修复完成！"
echo ""
echo "🌐 请在浏览器中访问："
echo "   http://188.166.250.114/training"
echo ""
echo "📝 如果仍然有问题，查看错误日志："
echo "   tail -f /var/log/nginx/error.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

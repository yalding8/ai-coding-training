# AI Coding Training 项目开发规则

## 核心原则

1. **简洁至上 (KISS)**: 恪守KISS原则，崇尚简洁与可维护性，避免过度工程化
2. **深度分析**: 运用第一性原理，将问题拆解到最基础要素
3. **事实为本**: 以事实为最高准则，发现错误立即修正
4. **坚守本心**: 时刻记得项目核心目标，不做无关延展

## 部署与配置规范

### Nginx 配置规则

#### 必须遵守的配置标准

1. **try_files 指令**
   ```nginx
   # ✅ 正确写法
   location / {
       try_files $uri $uri/ /index.html;
   }
   
   # ❌ 错误写法（会导致重定向循环）
   location / {
       try_files / /index.html;
   }
   ```
   
2. **SSL 配置**
   - 必须同时监听 80 和 443 端口
   - 不强制 HTTP 到 HTTPS 重定向（兼容 Cloudflare Flexible 模式）
   - 自动检测 SSL 证书是否存在
   
   ```nginx
   # ✅ 正确配置
   server {
       listen 80;
       listen 443 ssl;
       server_name training.pylosy.com;
       
       # SSL 证书配置
       ssl_certificate /etc/letsencrypt/live/training.pylosy.com/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/training.pylosy.com/privkey.pem;
       
       # 不添加强制重定向
   }
   ```

3. **变量转义**
   - Shell 脚本中生成 Nginx 配置时，必须正确转义 `$` 符号
   - 使用 `\$uri` 而不是 `$uri`（在 heredoc 中）
   - 或使用单引号 heredoc：`<< 'EOF'`

#### 配置验证流程

每次修改 Nginx 配置后必须执行：

```bash
# 1. 语法检查
nginx -t

# 2. 重载配置
systemctl reload nginx

# 3. 验证访问
curl -I http://YOUR_DOMAIN
curl -I https://YOUR_DOMAIN

# 4. 检查重定向链
curl -L -v http://YOUR_DOMAIN 2>&1 | grep -i location
```

### 部署脚本规范

#### deploy-smart.sh 开发规则

1. **配置生成**
   - 使用单引号 heredoc 避免变量展开问题：`<< 'EOF'`
   - 或正确转义所有 Nginx 变量：`\$uri`, `\$host`
   
2. **SSL 自动检测**
   ```bash
   # 必须检查证书是否存在
   if [ -d "/etc/letsencrypt/live/DOMAIN" ]; then
       # 配置 HTTPS
   else
       # 仅配置 HTTP
   fi
   ```

3. **配置模板验证**
   - 每次修改配置模板后，必须在测试环境验证
   - 使用 `nginx -T` 检查最终生成的配置
   - 确保没有语法错误和逻辑错误

4. **错误处理**
   ```bash
   # 每个关键步骤都要检查返回值
   nginx -t && systemctl reload nginx || {
       echo "❌ Nginx 配置错误"
       exit 1
   }
   ```

### Cloudflare 集成规范

1. **SSL/TLS 模式**
   - 推荐使用：**Full** 或 **Full (Strict)**
   - 避免使用：**Flexible**（会导致重定向循环）

2. **重定向规则**
   - 不在源站配置强制 HTTPS 重定向
   - 让 Cloudflare 处理 HTTP → HTTPS 跳转
   - 源站只负责内容服务

3. **测试方法**
   ```bash
   # 绕过 Cloudflare 直连源站测试
   curl -I -H "Host: DOMAIN" http://SERVER_IP
   
   # 通过 Cloudflare 测试
   curl -I http://DOMAIN
   curl -I https://DOMAIN
   ```

## 代码审查检查清单

### 部署相关修改必查项

- [ ] Nginx `try_files` 指令是否正确（必须包含 `$uri $uri/`）
- [ ] Shell 脚本中的 Nginx 变量是否正确转义
- [ ] SSL 证书路径是否正确
- [ ] 是否有不必要的重定向配置
- [ ] 配置是否兼容 Cloudflare
- [ ] 是否添加了配置验证步骤

### 测试验证必做项

- [ ] 本地语法检查：`nginx -t`
- [ ] 直连源站测试（绕过 CDN）
- [ ] 通过 CDN 测试
- [ ] HTTP 访问测试
- [ ] HTTPS 访问测试
- [ ] 重定向链检查
- [ ] 清除缓存后的浏览器测试

## 故障排查流程

### 遇到 ERR_TOO_MANY_REDIRECTS

1. **检查源站配置**
   ```bash
   # 直连源站测试
   curl -I -H "Host: DOMAIN" http://SERVER_IP
   
   # 查看 Nginx 配置
   nginx -T | grep -A 20 "server_name DOMAIN"
   
   # 检查 try_files 指令
   nginx -T | grep try_files
   ```

2. **检查 Cloudflare 设置**
   - SSL/TLS 模式
   - Always Use HTTPS 设置
   - Page Rules 重定向规则

3. **修复步骤**
   - 修正 Nginx 配置
   - 重载 Nginx
   - 清除 Cloudflare 缓存
   - 清除浏览器缓存
   - 使用无痕模式测试

## 文档更新规范

每次修复重大问题后必须：

1. **更新故障排查文档**
   - 记录问题原因
   - 记录解决方案
   - 添加预防措施

2. **更新部署文档**
   - 补充注意事项
   - 更新最佳实践
   - 添加验证步骤

3. **更新开发规则**（本文档）
   - 总结经验教训
   - 制定预防规则
   - 完善检查清单

## 版本控制规范

### Commit Message 规范

```
<type>: <subject>

<body>

<footer>
```

**Type 类型：**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例：**
```
fix: correct try_files directive in Nginx config

- Change from 'try_files / /index.html' to 'try_files $uri $uri/ /index.html'
- Fixes ERR_TOO_MANY_REDIRECTS issue
- Add validation in deploy script

Closes #123
```

## 持续改进

### 定期审查

- 每月审查一次部署脚本
- 每季度审查一次 Nginx 配置
- 发现问题立即更新规则

### 知识沉淀

- 重大问题必须形成文档
- 解决方案必须可复现
- 经验教训必须制度化

---

**最后更新**: 2026-01-17  
**维护者**: AI Coding Training Team  
**版本**: 1.0.0

## 附录：常见错误案例

### 案例 1：try_files 指令错误

**错误配置：**
```nginx
location / {
    try_files / /index.html;
}
```

**问题**：导致无限重定向循环

**正确配置：**
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

**预防措施**：
- 使用配置模板
- 部署前验证
- 自动化测试

### 案例 2：SSL 重定向循环

**错误配置：**
```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}
```

**问题**：与 Cloudflare Flexible 模式冲突

**正确配置：**
```nginx
server {
    listen 80;
    listen 443 ssl;
    # 不添加重定向，让 Cloudflare 处理
}
```

**预防措施**：
- 了解 CDN 工作原理
- 测试不同 SSL 模式
- 文档化最佳实践

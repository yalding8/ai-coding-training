# 解决 ERR_TOO_MANY_REDIRECTS 问题

## 问题原因

`ERR_TOO_MANY_REDIRECTS` 重定向循环通常是由 **Cloudflare SSL/TLS 设置** 与源站配置不匹配导致的。

## 彻底解决方案

### 方案 1：修改 Cloudflare SSL 设置（推荐）

1. **登录 Cloudflare Dashboard**
   - 访问：https://dash.cloudflare.com
   - 选择域名：`pylosy.com`

2. **修改 SSL/TLS 设置**
   - 进入：`SSL/TLS` → `Overview`
   - 将加密模式改为：**Full** 或 **Full (Strict)**
   - ⚠️ **不要使用 Flexible 模式**（会导致重定向循环）

3. **检查 Always Use HTTPS**
   - 进入：`SSL/TLS` → `Edge Certificates`
   - 找到 "Always Use HTTPS"
   - **建议关闭**（或确保源站没有重定向）

4. **检查 Page Rules**
   - 进入：`Rules` → `Page Rules`
   - 检查是否有针对 `training.pylosy.com` 的重定向规则
   - 如果有，暂时禁用

5. **清除缓存**
   - 进入：`Caching` → `Configuration`
   - 点击 "Purge Everything"
   - 清除浏览器缓存（Ctrl/Cmd + Shift + Delete）

### 方案 2：暂时绕过 Cloudflare（测试用）

如果需要立即访问，可以暂时绕过 Cloudflare：

1. **修改本地 hosts 文件**
   ```bash
   # Mac/Linux
   sudo nano /etc/hosts
   
   # Windows
   # 以管理员身份编辑 C:\Windows\System32\drivers\etc\hosts
   ```

2. **添加以下行**
   ```
   188.166.250.114 training.pylosy.com
   ```

3. **访问**
   - 直接访问：https://training.pylosy.com
   - 绕过 Cloudflare，直连源站

### 方案 3：使用 IP 直接访问（临时）

直接使用服务器 IP 访问（不经过 Cloudflare）：

```
http://188.166.250.114
```

⚠️ 注意：IP 访问时 SSL 证书会不匹配（因为证书是为域名颁发的）

## 推荐配置

### Cloudflare 最佳实践

**SSL/TLS 设置：**
- 加密模式：**Full (Strict)**
- Always Use HTTPS：**关闭**（或确保源站配置正确）
- Automatic HTTPS Rewrites：**开启**
- Minimum TLS Version：**TLS 1.2**

**源站配置（已完成）：**
- ✅ Nginx 同时监听 80 和 443
- ✅ 有效的 SSL 证书（Let's Encrypt）
- ✅ 无强制重定向

## 验证步骤

1. **修改 Cloudflare 设置后**，等待 2-5 分钟（DNS 传播）
2. **清除浏览器缓存**（重要！）
3. **使用无痕模式**访问：https://training.pylosy.com
4. **检查是否正常**

## 如果仍然有问题

运行以下命令检查：

```bash
# 检查 DNS 解析
nslookup training.pylosy.com

# 检查 HTTP 响应
curl -I http://training.pylosy.com

# 检查 HTTPS 响应
curl -I https://training.pylosy.com

# 检查重定向链
curl -L -v http://training.pylosy.com 2>&1 | grep -i location
```

## 联系方式

如果以上方法都无法解决，请提供：
1. Cloudflare SSL/TLS 设置截图
2. `curl -I https://training.pylosy.com` 的完整输出
3. 浏览器开发者工具 Network 面板截图

---

**最后更新**: 2026-01-17
**维护者**: AI Coding Training Team

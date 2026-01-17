# GitHub Actions 自动部署配置指南

## 概述

本项目使用 GitHub Actions 实现自动化部署。每次推送代码到 `main` 分支时，会自动部署到生产服务器。

## 配置步骤

### 1. 添加 GitHub Secrets

在 GitHub 仓库页面：

1. 进入 `Settings` → `Secrets and variables` → `Actions`
2. 点击 `New repository secret`
3. 添加以下三个 Secrets：

| Name | Value | 说明 |
|------|-------|------|
| `SERVER_HOST` | `188.166.250.114` | 服务器 IP 地址 |
| `SERVER_USER` | `root` | SSH 登录用户名 |
| `SSH_PRIVATE_KEY` | `<私钥内容>` | SSH 私钥（完整内容） |

#### 获取 SSH 私钥

```bash
# 查看私钥
cat ~/.ssh/id_ed25519

# 应该看到类似这样的内容（全部复制）
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
...（很多行）...
-----END OPENSSH PRIVATE KEY-----
```

⚠️ **重要**：必须复制 **完整内容**，包括 `BEGIN` 和 `END` 行。

### 2. 验证服务器环境

确保服务器上已配置好：

```bash
# SSH 到服务器
ssh root@188.166.250.114

# 检查项目目录
ls -la /var/www/ai-coding-training

# 检查 Git 配置
cd /var/www/ai-coding-training
git remote -v
git status
```

### 3. 测试部署

#### 方式 A：推送代码触发

```bash
# 本地修改代码
echo "test" >> README.md

# 提交并推送
git add .
git commit -m "test: trigger GitHub Actions"
git push origin main
```

#### 方式 B：手动触发

1. 进入 GitHub 仓库
2. 点击 `Actions` 标签
3. 选择 `Deploy to Production`
4. 点击 `Run workflow`
5. 选择 `main` 分支
6. 点击 `Run workflow` 按钮

### 4. 查看部署日志

1. GitHub 仓库 → `Actions` 标签
2. 找到最新的 workflow run
3. 点击查看详细日志

每个步骤的执行结果都会显示：
- ✅ 成功
- ❌ 失败

## 工作流程详解

### 触发条件

```yaml
on:
  push:
    branches:
      - main           # 推送到 main 分支触发
  workflow_dispatch:   # 支持手动触发
```

### 部署步骤

1. **检出代码** (`checkout`)
   - 从 GitHub 拉取最新代码

2. **SSH 连接服务器** (`ssh-action`)
   - 使用配置的 Secrets 连接服务器
   - 执行部署脚本

3. **服务器端操作**
   ```bash
   cd /var/www/ai-coding-training
   git fetch origin
   git reset --hard origin/main  # 强制同步
   nginx -t && systemctl reload nginx  # 重载 Nginx
   ```

4. **通知**
   - 成功：显示部署成功 ✅
   - 失败：提示检查日志 ❌

## 故障排查

### 常见问题

#### 1. SSH 连接失败

**错误信息**：
```
Permission denied (publickey)
```

**解决方案**：
- 检查 `SSH_PRIVATE_KEY` 是否完整
- 确保私钥格式正确（包含 BEGIN/END 行）
- 验证公钥已添加到服务器 `~/.ssh/authorized_keys`

#### 2. Git pull 失败

**错误信息**：
```
error: Your local changes would be overwritten
```

**解决方案**：
- 工作流使用 `git reset --hard` 强制同步
- 不应该在服务器上手动修改文件

#### 3. Nginx 重载失败

**错误信息**：
```
nginx: configuration file test failed
```

**解决方案**：
- 检查 Nginx 配置语法
- 查看错误日志：`/var/log/nginx/error.log`

### 调试方法

1. **查看 GitHub Actions 日志**
   - 完整的执行过程都有记录
   - 可以看到每个命令的输出

2. **手动 SSH 测试**
   ```bash
   ssh root@188.166.250.114 "cd /var/www/ai-coding-training && git status"
   ```

3. **检查服务器状态**
   ```bash
   ssh root@188.166.250.114
   systemctl status nginx
   tail -f /var/log/nginx/ai-coding-training.error.log
   ```

## 安全最佳实践

### Secrets 管理

- ✅ **不要** 将私钥提交到代码库
- ✅ **使用** GitHub Secrets 存储敏感信息
- ✅ **定期轮换** SSH 密钥
- ✅ **限制** SSH 密钥权限（只用于部署）

### 服务器安全

- ✅ 使用防火墙限制 SSH 访问
- ✅ 禁用密码登录，只用密钥
- ✅ 定期更新服务器软件
- ✅ 监控异常部署行为

## 进阶配置

### 添加测试步骤

```yaml
- name: Run tests
  run: |
    # 添加你的测试命令
    echo "Running tests..."
```

### 添加通知

```yaml
- name: Send notification
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 多环境部署

```yaml
on:
  push:
    branches:
      - main      # 生产环境
      - develop   # 开发环境
```

## 参考资料

- [GitHub Actions 文档](https://docs.github.com/actions)
- [appleboy/ssh-action](https://github.com/appleboy/ssh-action)
- [项目开发规则](DEVELOPMENT_RULES.md)

---

**最后更新**: 2026-01-17  
**维护者**: AI Coding Training Team

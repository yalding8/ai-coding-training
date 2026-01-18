# Google Analytics 4 配置指南

## 📊 概述

本项目已集成 Google Analytics 4 (GA4) 流量统计功能，支持实时追踪和详细的用户行为分析。

## 🚀 快速配置（5分钟）

### Step 1: 创建 GA4 账号

1. **访问 Google Analytics**
   👉 https://analytics.google.com/

2. **创建账号**
   - 点击"开始衡量"
   - 账号名称：`Uhomes AI Training`
   - 勾选数据共享设置（可选）

3. **创建媒体资源**
   - 媒体资源名称：`AI Coding Training`
   - 报告时区：`(GMT+08:00) 中国时间 - 北京`
   - 货币：`人民币 (CNY ¥)`

4. **关于您的商家**
   - 行业类别：`教育`
   - 商家规模：`中小型`
   - 使用 Analytics 的意图：`衡量网站流量`

5. **创建数据流**
   - 选择平台：`网站`
   - 网站 URL：`https://training.pylosy.com`
   - 数据流名称：`AI Coding Training - Web`

6. **获取衡量 ID**
   - 完成后会显示衡量 ID
   - 格式：`G-XXXXXXXXXX`
   - **复制此 ID**

### Step 2: 配置网站代码

找到 `index.html` 和 `demo.html` 中的以下代码：

```html
<!-- 替换 GA_MEASUREMENT_ID 为你的实际 ID (格式: G-XXXXXXXXXX) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
```

**替换两处 `GA_MEASUREMENT_ID`**：

1. 第9行的 script src
2. 第15行的 gtag('config'

示例：
```html
<!-- 替换前 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
    gtag('config', 'GA_MEASUREMENT_ID', {

<!-- 替换后 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-ABC1234XYZ"></script>
<script>
    gtag('config', 'G-ABC1234XYZ', {
```

### Step 3: 部署更新

```bash
# 提交代码
git add index.html demo.html
git commit -m "feat: configure Google Analytics tracking"
git push origin main

# GitHub Actions 会自动部署
```

### Step 4: 验证安装

1. **实时检查**
   - 访问：https://analytics.google.com
   - 进入你的媒体资源
   - 点击左侧菜单：`报告` → `实时`
   - 在另一个浏览器窗口打开：https://training.pylosy.com
   - 应该能在实时报告中看到自己

2. **使用 GA Debugger（可选）**
   - 安装 Chrome 插件：[Google Analytics Debugger](https://chrome.google.com/webstore/detail/google-analytics-debugger/jnkmfdileelhofjcijamephohjechhna)
   - 访问网站，打开F12控制台
   - 查看GA事件是否正常发送

---

## 📈 功能说明

### 自动追踪的数据

#### 1. 基础数据
- ✅ **页面浏览量 (Page Views)**
- ✅ **用户数 (Users)**
- ✅ **会话数 (Sessions)**
- ✅ **平均会话时长**
- ✅ **跳出率**

#### 2. 用户来源
- ✅ **流量来源**（直接访问、搜索、社交等）
- ✅ **地理位置**（国家、城市）
- ✅ **设备类型**（桌面、移动、平板）
- ✅ **浏览器和操作系统**

#### 3. 自定义事件

| 事件名称 | 触发时机 | 参数 |
|---------|---------|------|
| `scroll_depth` | 滚动到25%、50%、75%、100% | `scroll_percentage` |
| `github_link_click` | 点击GitHub项目链接 | `project_name`, `link_url` |
| `navigation_click` | 点击导航菜单 | `section` |
| `demo_page_click` | 点击Demo教程按钮 | `button_text` |
| `code_copy` | 点击代码复制按钮 | `button_type` |
| `page_load` | 页面加载完成 | `load_time_ms` |
| `time_on_page` | 离开页面 | `duration_seconds` |

---

## 📊 查看数据

### 实时报告

1. **访问实时报告**
   - Google Analytics → 你的媒体资源
   - 左侧菜单：`报告` → `实时`

2. **实时数据包括**：
   - 💚 **当前在线用户数**
   - 👤 过去30分钟的用户数
   - 📄 用户正在浏览的页面
   - 📍 用户所在地理位置
   - 🖥️ 用户使用的设备
   - 🔗 用户来自哪里（流量来源）

### 标准报告

#### 流量获取
**路径**：`报告` → `生命周期` → `获客` → `流量获取`

查看：
- 用户从哪里来（搜索、直接访问、社交媒体等）
- 各渠道的表现对比
- 转化率分析

#### 互动度
**路径**：`报告` → `生命周期` → `互动度`

查看：
- 页面浏览量和屏幕浏览量
- 事件计数
- 转化次数
- 最受欢迎的页面

#### 用户属性
**路径**：`报告` → `用户` → `用户属性`

查看：
- 地理位置分布
- 设备类型分布
- 浏览器和操作系统

#### 事件报告
**路径**：`报告` → `互动度` → `事件`

查看所有自定义事件：
- GitHub链接点击统计
- 导航使用情况
- 滚动深度分析
- 代码复制次数

---

## 🎯 重点关注的指标

### 培训效果评估

1. **参与度指标**
   ```
   - 平均会话时长 > 5分钟（说明用户认真阅读）
   - 滚动深度 > 75%（说明内容吸引人）
   - 跳出率 < 40%（说明用户有继续浏览兴趣）
   ```

2. **内容受欢迎程度**
   ```
   - navigation_click 事件：哪个章节最受关注
   - scroll_depth：用户是否看完整页面
   - github_link_click：哪个项目最受欢迎
   ```

3. **Demo教程效果**
   ```
   - demo_page_click：有多少人点击查看教程
   - demo.html 的页面浏览量
   - code_copy：有多少人复制代码实践
   ```

### 创建自定义报告

1. **进入探索功能**
   - 左侧菜单：`探索`
   - 点击"空白"创建新探索

2. **创建"培训效果仪表板"**
   
   **维度**：
   - 页面路径和屏幕类（Page path and screen class）
   - 事件名称（Event name）
   - 城市（City）

   **指标**：
   - 用户数
   - 会话数
   - 平均互动时长
   - 事件计数

   **可视化**：
   - 折线图：显示每日用户趋势
   - 饼图：显示设备类型分布
   - 表格：显示最受欢迎的章节

---

## 🔬 高级功能

### 1. 设置转化目标

如果你想追踪特定目标（例如：访问Demo页面）

1. **标记转化**
   - 进入：`管理` → `事件`
   - 找到 `demo_page_click` 事件
   - 打开"标记为转化"开关

2. **查看转化报告**
   - `报告` → `生命周期` → `互动度` → `转化`

### 2. 受众群体创建

创建特定用户群体（例如：深度阅读用户）

1. **创建受众群体**
   - `管理` → `受众群体` → `新建受众群体`

2. **定义条件**
   ```
   条件：scroll_depth >= 75
   且 time_on_page >= 300秒
   ```

3. **用途**
   - 分析深度用户的特征
   - 了解哪些内容最吸引人

### 3. 数据导出

**导出到Google Sheets**：
1. 打开任何报告
2. 点击右上角"共享此报告"
3. 选择"下载文件" → Google Sheets

**导出到BigQuery**（高级）：
- `管理` → `BigQuery链接`
- 适合大规模数据分析

---

## 📱 移动端 App

**下载 Google Analytics App**：
- iOS: [App Store](https://apps.apple.com/app/google-analytics/id881599038)
- Android: [Google Play](https://play.google.com/store/apps/details?id=com.google.android.apps.giant)

**随时随地查看数据**：
- 📊 实时用户数
- 📈 流量趋势
- 🔔 异常流量警报
- 📧 定时报告邮件

---

## ⚠️ 隐私合规

### GDPR / 个人信息保护

GA4 已集成隐私保护功能：
- ✅ IP匿名化（自动）
- ✅ 数据保留设置（可配置）
- ✅ 用户数据删除请求支持

### 可选：添加Cookie同意横幅

如果需要更严格的隐私合规：

```html
<!-- 简单的Cookie提示 -->
<div id="cookie-notice" style="...">
    本站使用 Google Analytics 来改善用户体验。
    <button onclick="acceptCookies()">接受</button>
</div>

<script>
function acceptCookies() {
    localStorage.setItem('cookiesAccepted', 'true');
    document.getElementById('cookie-notice').style.display = 'none';
    // 初始化GA
}

if (localStorage.getItem('cookiesAccepted') === 'true') {
    // GA已在head中初始化
} else {
    document.getElementById('cookie-notice').style.display = 'block';
}
</script>
```

---

## 🐛 故障排查

### 问题1：实时报告中看不到数据

**检查清单**：
- [ ] GA_MEASUREMENT_ID 是否正确替换
- [ ] 网站是否已部署最新代码
- [ ] 浏览器是否启用JavaScript
- [ ] 浏览器是否安装了广告拦截器（暂时禁用测试）
- [ ] 检查浏览器控制台是否有错误

**验证GA加载**：
```javascript
// 在浏览器控制台执行
console.log(window.dataLayer);
// 应该看到一个数组
```

### 问题2：事件没有被追踪

**检查**：
1. 打开浏览器开发者工具（F12）
2. 切换到"Network"标签
3. 筛选："gtag" 或 "collect"
4. 触发事件（例如点击GitHub链接）
5. 查看是否有新的网络请求

### 问题3：数据延迟

GA4 数据处理延迟：
- **实时报告**：几乎即时（<1分钟）
- **标准报告**：24-48小时

---

## 📚 参考资料

- [GA4 官方文档](https://support.google.com/analytics/answer/10089681)
- [GA4 事件参考](https://developers.google.com/analytics/devguides/collection/ga4/events)
- [GA4 最佳实践](https://support.google.com/analytics/topic/9303474)

---

**配置完成后**，你将能够：
- 📊 实时查看有多少人在访问
- 👥 了解用户来自哪里
- 📱 知道使用什么设备
- 🔍 分析哪些内容最受欢迎
- 📈 追踪培训效果

**需要帮助？**
查看 [Google Analytics 帮助中心](https://support.google.com/analytics/)

---

**最后更新**: 2026-01-18  
**维护者**: AI Coding Training Team

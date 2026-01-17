import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# 1. 读取数据
print("📊 读取数据...")
df = pd.read_csv('sales_data.csv')
df['日期'] = pd.to_datetime(df['日期'])

# 2. 数据分析
print("🔍 分析数据...")
# 按地区汇总
region_summary = df.groupby('地区').agg({
    '销售额': 'sum',
    '订单数': 'sum'
}).reset_index()
region_summary = region_summary.sort_values('销售额', ascending=False)

# 3. 创建图表
print("📈 生成图表...")

# 创建子图布局（2行2列）
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=('销售额趋势', '地区销售对比', 'Top 5 地区排行', '订单数分布'),
    specs=[[{"type": "scatter"}, {"type": "bar"}],
           [{"type": "bar"}, {"type": "pie"}]]
)

# 图表1：销售额趋势
fig.add_trace(
    go.Scatter(
        x=df['日期'],
        y=df['销售额'],
        mode='lines+markers',
        name='销售额',
        line=dict(color='#00ffaa', width=3),
        marker=dict(size=8)
    ),
    row=1, col=1
)

# 图表2：地区销售对比
fig.add_trace(
    go.Bar(
        x=region_summary['地区'],
        y=region_summary['销售额'],
        name='地区销售额',
        marker=dict(color='#ff6b35')
    ),
    row=1, col=2
)

# 图表3：Top 5 排行
top5 = region_summary.head(5)
fig.add_trace(
    go.Bar(
        x=top5['销售额'],
        y=top5['地区'],
        orientation='h',
        name='Top 5',
        marker=dict(color='#00ffaa')
    ),
    row=2, col=1
)

# 图表4：订单数分布（饼图）
fig.add_trace(
    go.Pie(
        labels=region_summary['地区'],
        values=region_summary['订单数'],
        name='订单分布'
    ),
    row=2, col=2
)

# 4. 更新布局
fig.update_layout(
    title_text="业务数据看板",
    title_font_size=24,
    showlegend=True,
    height=800,
    template='plotly_dark'
)

# 5. 保存为 HTML
output_file = 'dashboard.html'
fig.write_html(output_file)
print(f"✅ 看板已生成：{output_file}")
print(f"🌐 请在浏览器中打开 {output_file} 查看结果")

import os
from openai import OpenAI

# 从环境变量中获取API Key
api_key = os.getenv("sk-5NGKz6XpSBlPGXFAxYc1Y6DIRs4yQhqG7JPw8WaMSpVNLa0y")

# 初始化OpenAI客户端
client = OpenAI(
    api_key=api_key,
    base_url="https://api.moonshot.cn/v1"  # 根据实际情况调整base_url
)

# 定义对话内容
question = "请问文章《出师表》中最有名的一段内容是？"
messages = [
    {"role": "system", "content": "你是Kimi，由Moonshot AI提供的人工智能助手，你更擅长中文和英文的对话。"},
    {"role": "user", "content": question}
]

# 调用大模型API进行对话
completion = client.chat.completions.create(
    model="moonshot-v1-32k",  # 根据实际情况调整模型名称
    messages=messages,
    temperature=0.2,
)

# 输出大模型的回答
message_data = completion.choices[0].message
print("Kimi 返回信息:", message_data)
content_ = message_data.content
print("Kimi 回答:", content_)
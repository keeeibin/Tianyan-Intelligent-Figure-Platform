from openai import OpenAI
import re
import subprocess
import os
import matlab.engine

# 创建OpenAI客户端实例
client = OpenAI(
    api_key="sk-5NGKz6XpSBlPGXFAxYc1Y6DIRs4yQhqG7JPw8WaMSpVNLa0y",  # 替换为你的API密钥
    base_url="https://api.moonshot.cn/v1",
)

# 系统角色的初始消息
system_message = {
    "role": "system",
    "content": "你是 Kimi，由 Moonshot AI 提供的人工智能助手，你更擅长中文和英文的对话。\
        你会为用户提供安全，有帮助，准确的回答。同时，你会拒绝一切涉及恐怖主义，种族歧视，黄色暴力等问题的回答。\
        Moonshot AI 为专有名词，不可翻译成其他语言。"
}

# -*- coding: utf-8 -*-
def is_python_code(text):
    # 一个简单的正则表达式来识别Python代码块
    #code_pattern = re.compile(r'```python(.*?)```', re.DOTALL)
    code_pattern = re.compile(r'```matlab(.*?)```', re.DOTALL)
    return code_pattern.search(text)

# -*- coding: utf-8 -*-
def execute_python_code(code):
    # 使用subprocess在隔离的环境中执行Python代码
    try:
        # 将代码保存到一个临时文件中
        with open('temp.py', 'w') as f:
            f.write("# -*- coding: utf-8 -*-\n")  # 写入编码声明
            f.write(code)

        # 执行代码并捕获输出
        result = subprocess.run(['python', 'temp.py'], capture_output=True, text=True, check=True)

        # 返回输出结果
        return result.stdout
    except subprocess.CalledProcessError as e:
        # 如果代码执行出错，返回错误信息
        return e.stderr

conversation_history = []

# 开始对话
print("对话开始，输入'退出'结束对话。")
while True:
    # 用户输入问题
    user_question = input("\n你：")
    if user_question == "退出":
        print("对话结束。")
        break  # 退出循环，结束对话

    # 将当前回合添加到对话历史
    conversation_history.append({"role": "user", "content": user_question})

    # 调用API生成回答
    completion = client.chat.completions.create(
        model="moonshot-v1-32k",  # 模型选择
        messages=[system_message, {"role": "user", "content": user_question}] + conversation_history,
        temperature=0.2,
    )

    # 提取并打印Kimi的回答
    message_data = completion.choices[0].message
    print("\nKimi 返回信息:", message_data)
    content_ = message_data.content
    print("Kimi 回答:", content_)

    # 将Kimi的回答添加到对话历史
    conversation_history.append({"role": "assistant", "content": content_})

    code_match = is_python_code(content_)
    if code_match:
        code = code_match.group(1).strip()
        m_file_name = "matlab_tempt.m"
        with open(m_file_name, "w") as file:
            file.write(code)
        eng = matlab.engine.start_matlab()
        eng.eval('run("{}")'.format(m_file_name), nargout=0)
        # with open('plot_script.m', 'w') as f:
        #     f.write("# -*- coding: utf-8 -*-\n")  # 写入编码声明
        #     f.write(code)
        #print("\n识别到的Python代码：")
        #print(code)

        # 执行代码
        # output = execute_python_code(code)
        #print("代码执行结果：")
        #print(output)
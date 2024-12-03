
%%配置模型
%设置每次聊天会话允许的最大字数，并定义关键字，当用户输入该关键字时，该关键字将结束聊天会话。


%创建一个实例ollamaChat来执行聊天，创建一个实例messageHistory来存储会话历史记录。
%chat = ollamaChat("qwen2:7b");


%% 聊天循环
% 开始聊天并保持聊天，直到出现stopWord设置的语句出现


%%
% 创建主窗口
hFig = figure('Position', [100, 100, 300, 200], ...
              'Name', 'My GUI', ...
              'NumberTitle', 'off', ...
              'MenuBar', 'none', ...
              'ToolBar', 'none', ...
              'Resize', 'off');

% 创建一个标签
hLabel = uicontrol('Style', 'text', ...
                   'Position', [50, 150, 200, 25], ...
                   'String', 'Query');

% 创建一个文本框
hEdit = uicontrol('Style', 'edit', ...
                 'Position', [50, 120, 200, 25]);

% 创建一个按钮
hButton = uicontrol('Style', 'pushbutton', ...
                    'Position', [50, 80, 100, 25], ...
                    'String', 'Answer', ...
                    'Callback', @(src, event) buttonCallback(src, event, hEdit));



% 按钮的回调函数
function buttonCallback(src, event, hEdit)
    % 获取文本框中的文本
   wordLimit = 2000;
    stopWord = "end";
    totalWords = 0;
    messagesSizes = [];
    messages = messageHistory;
    system_prompt = "You are a helpful assistant. You might get a context for each question, but only use the information in the context if that makes sense to answer the question. ";
    chat = ollamaChat("llama3", system_prompt);
%% 
% 主循环会无限地继续下去，直到输入设置好的stopWord或按下Ctrl+ c 
while true
    query = get(hEdit, 'String');

    % 检查文本框是否为空
    if isempty(query)
        query = 'Guest';
    end
    % query = input("User: ", "s");
    query = string(query);
    dispWrapped("User", query)
%% 
% 如果您输入了stopWord，则显示消息并退出循环。

    % if query == stopWord
    %     disp("AI: Closing the chat. Have a great day!")
    %     break;
    % end

    numWordsQuery = countNumWords(query);
%% 
% 如果查询超过字数限制，则显示错误消息并停止执行。

    if numWordsQuery>wordLimit
        error("Your query should have fewer than " + wordLimit + " words. You query had " + numWordsQuery + " words.")
    end
%% 
% 跟踪每条消息的大小和到目前为止使用的总字数。

    messagesSizes = [messagesSizes; numWordsQuery]; %#ok
    totalWords = totalWords + numWordsQuery;
%% 
% 如果总字数超过限制，则从会话开始时删除消息，直到不再使用为止。

    while totalWords > wordLimit
        totalWords = totalWords - messagesSizes(1);
        messages = removeMessage(messages, 1);
        messagesSizes(1) = [];
    end
%% 
% 将新消息添加到会话并生成新的响应。

    messages = addUserMessage(messages, query);
    [text, response] = generate(chat, messages);

    dispWrapped("AI", text)
%% 
% 计算回复中的字数并更新总字数。

    numWordsResponse = countNumWords(text);
    messagesSizes = [messagesSizes; numWordsResponse]; %#ok
    totalWords = totalWords + numWordsResponse;
%% 
% 向会话添加响应。
%%
    messages = addResponseMessage(messages, response);
    pattern_getcode = '```matlab\s*(.*?)\s*```'; % 匹配代码块
    matches_getcode = regexp(text, pattern_getcode, 'tokens');


% 检查是否找到了匹配
if ~isempty(matches_getcode)
    % 提取第一个匹配的代码块
    codeBlock = matches_getcode{1}{1};

    % 打印提取的代码块（可选）
    disp('提取的代码块:');
    disp(codeBlock);

    % 使用 eval 执行提取的代码
    eval(codeBlock);
    drawnow;
else
    disp('未找到 MATLAB 代码块。');
end

if ~isempty(matches_getcode)
    eval(codeBlock);
end

end
    % 显示问候语
    % message = ['Hello, ' name];
    % msgbox(message, 'Greeting');
end

% 运行 GUI

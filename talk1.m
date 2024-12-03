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

%% |Helper Functions|
% 该函数用于计算文本字符串中的单词数
% buttonCallback(src, event, hEdit)

function numWords = countNumWords(text)
    numWords = doclength(tokenizedDocument(text));
end
%% 
% 该函数显示从前缀挂起缩进的换行文本

function dispWrapped(prefix, text)
    indent = [newline, repmat(' ',1,strlength(prefix)+2)];
    text = strtrim(text);
    disp(prefix + ": " + join(textwrap(text, 70),indent))
end
%%

% 全局变量用于存储消息历史
global messages;
% messages = struct('user', {}, 'response', {});

%%

% 按钮的回调函数
function buttonCallback(src, event, hEdit)
    % 获取文本框中的文本
    query = get(hEdit, 'String');
    if isempty(query)
        query = 'Guest';
    end
    query = string(query);
    dispWrapped("User", query);

    % 检查是否为特定的停止词，如果是，则退出
    if query == "end"
        disp("AI: Closing the chat. Have a great day!");
        return;
    end

    % 调用处理函数，传入用户输入和编辑框句柄
    processInput(query, hEdit);
end

% 处理用户输入的函数
function processInput(query, hEdit)
    system_prompt = "You are a helpful assistant. You might get a context for each question, but only use the information in the context if that makes sense to answer the question. ";
    chat = ollamaChat("llama3", system_prompt);
    wordLimit = 2000;
    stopWord = "end";
    messages = messageHistory;
    totalWords = 0;
    messagesSizes = [];
    numWordsQuery = countNumWords(query);
    
    if numWordsQuery > wordLimit
        error("Your query should have fewer than " + wordLimit + " words. You query had " + numWordsQuery + " words.");
    end

    messagesSizes = [messagesSizes; numWordsQuery]; 
    totalWords = totalWords + numWordsQuery;

    while totalWords > wordLimit
        totalWords = totalWords - messagesSizes(1);
        messages = removeMessage(messages, 1);
        messagesSizes(1) = [];
    end

    % messages.user(end+1) = query;
    messages = addUserMessage(messages, query);
    [text, response] = generate(chat, messages);
    dispWrapped("AI", text);

    numWordsResponse = countNumWords(text);
    messagesSizes = [messagesSizes; numWordsResponse]; 
    totalWords = totalWords + numWordsResponse;

    messages = addResponseMessage(messages, response);
    % messages.response(end+1) = response;
    pattern_getcode = '```matlab\s*(.*?)\s*```'; % 匹配代码块
    matches_getcode = regexp(text, pattern_getcode, 'tokens');

    if ~isempty(matches_getcode)
        codeBlock = matches_getcode{1}{1};
        disp('提取的代码块:');
        disp(codeBlock);
        eval(codeBlock);
    else
        disp('未找到 MATLAB 代码块。');
    end

    % 清空文本框，准备下一次输入
    set(hEdit, 'String', '');
    drawnow;
end


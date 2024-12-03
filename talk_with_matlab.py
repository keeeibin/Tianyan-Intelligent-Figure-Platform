import subprocess
import matlab.engine

#
# # MATLAB代码，作为字符串存储
# matlab_code = """
# figure;
# x = 0:0.1:2*pi;
# y = sin(x);
# plot(x, y);
# title('Sine Wave');
# xlabel('x');
# ylabel('sin(x)');
# """
#
# # 将MATLAB代码保存到.m文件
m_file_name = "plot_script.m"
# with open(m_file_name, "w") as file:
#     file.write(matlab_code)

# 构建调用MATLAB执行.m文件的命令
#matlab_command = ['matlab', '-batch', 'run("{}")'.format(m_file_name)]

eng = matlab.engine.start_matlab()
# 调用MATLAB执行.m文件
eng.eval('run("{}")'.format(m_file_name), nargout=0)

# 打印完成信息


# import matlab.engine
# eng = matlab.engine.start_matlab()
# x = matlab.double([25])
# result = eng.sqrt(x)
# print("The square root of 16 is:", result)
# eng.quit()
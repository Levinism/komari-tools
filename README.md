# Komari Agent Cleanup Tool

用于彻底清理 Linux 服务器上的 Komari Agent，方便重新通过 **Auto Discovery** 注册到 Komari 面板。

适合以下情况：

- 服务器以前安装过 Komari Agent
- 更换或重装了 Komari 主控
- Auto Discovery 一直返回 `401 Unauthorized`
- 日志中出现：


Using existing auto-discovery token for UUID: ...
不会删除什么

脚本不会删除：

/opt/komari/komari

因此如果当前服务器同时运行 Komari Server 主控，正常情况下不会影响 Komari 主控程序。

推荐使用流程
1. 一键清理
2. 确认清理成功

正常会看到：

✅ systemd 服务已删除
✅ Agent 进程已清除
✅ Agent 程序已删除
✅ Auto Discovery 旧身份文件已删除
3. 打开 Komari 后台

进入 Agent / Server 添加页面，复制新的 Auto Discovery 安装命令。

4. 在服务器执行新的安装命令


执行一键清理：
```text
bash <(curl -fsSL https://raw.githubusercontent.com/Levinism/komari-tools/main/clean-komari-agent.sh)





#!/bin/bash

echo "===== Komari Agent 清理开始 ====="

systemctl stop komari-agent 2>/dev/null || true
systemctl disable komari-agent 2>/dev/null || true

pkill -f '/opt/komari/agent' 2>/dev/null || true
pkill -f 'komari-agent' 2>/dev/null || true

rm -f /etc/systemd/system/komari-agent.service
rm -f /usr/lib/systemd/system/komari-agent.service
rm -f /lib/systemd/system/komari-agent.service
rm -rf /etc/systemd/system/komari-agent.service.d

rm -f /opt/komari/agent
rm -f /usr/local/bin/komari-agent
rm -f /usr/bin/komari-agent

rm -f /opt/komari/agent.json
rm -f /opt/komari/agent-config.json
rm -f /etc/komari-agent.json
rm -rf /etc/komari-agent

systemctl daemon-reload
systemctl reset-failed 2>/dev/null || true

echo
echo "===== 检查残留 ====="

if systemctl cat komari-agent >/dev/null 2>&1; then
    echo "⚠️ 仍发现 komari-agent systemd 服务"
else
    echo "✅ systemd 服务已清除"
fi

if pgrep -af '/opt/komari/agent|komari-agent' >/dev/null 2>&1; then
    echo "⚠️ 仍发现 Agent 进程："
    pgrep -af '/opt/komari/agent|komari-agent'
else
    echo "✅ Agent 进程已清除"
fi

if [ -f /opt/komari/agent ]; then
    echo "⚠️ /opt/komari/agent 仍存在"
else
    echo "✅ Agent 文件已清除"
fi

echo
echo "===== 清理完成 ====="
echo "现在可以回 Komari 后台删除旧节点，然后重新执行自动发现安装命令。"

#!/bin/bash

set +e

echo "======================================"
echo "   Komari Agent 一键彻底清理脚本"
echo "======================================"
echo

SERVICE="komari-agent"

echo "[1/6] 停止并禁用服务..."

systemctl stop ${SERVICE} 2>/dev/null || true
systemctl disable ${SERVICE} 2>/dev/null || true

echo "[2/6] 结束残留 Agent 进程..."

pkill -f '/opt/komari/agent' 2>/dev/null || true
pkill -f 'komari-agent' 2>/dev/null || true

sleep 1

echo "[3/6] 删除 systemd 服务..."

rm -f /etc/systemd/system/komari-agent.service
rm -f /etc/systemd/system/multi-user.target.wants/komari-agent.service
rm -f /usr/lib/systemd/system/komari-agent.service
rm -f /lib/systemd/system/komari-agent.service
rm -rf /etc/systemd/system/komari-agent.service.d

echo "[4/6] 删除 Agent 及自动发现身份文件..."

rm -f /opt/komari/agent
rm -f /opt/komari/auto-discovery.json

# 兼容可能存在的其他安装路径
rm -f /usr/local/bin/komari-agent
rm -f /usr/bin/komari-agent

echo "[5/6] 重载 systemd..."

systemctl daemon-reload 2>/dev/null || true
systemctl reset-failed 2>/dev/null || true

echo "[6/6] 检查清理结果..."
echo

if systemctl cat komari-agent >/dev/null 2>&1; then
    echo "❌ komari-agent.service 仍存在"
else
    echo "✅ systemd 服务已删除"
fi

if pgrep -af '/opt/komari/agent|komari-agent' >/dev/null 2>&1; then
    echo "❌ 仍发现 Agent 进程："
    pgrep -af '/opt/komari/agent|komari-agent'
else
    echo "✅ Agent 进程已清除"
fi

if [ -f /opt/komari/agent ]; then
    echo "❌ /opt/komari/agent 仍存在"
else
    echo "✅ Agent 程序已删除"
fi

if [ -f /opt/komari/auto-discovery.json ]; then
    echo "❌ /opt/komari/auto-discovery.json 仍存在"
else
    echo "✅ Auto Discovery 旧身份文件已删除"
fi

echo
echo "======================================"
echo "          清理完成"
echo "======================================"
echo
echo "现在可以重新执行 Komari 后台生成的 Auto Discovery 安装命令。"
echo
echo "注意："
echo "本脚本不会删除 /opt/komari/komari 主控程序。"

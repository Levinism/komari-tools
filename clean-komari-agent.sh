#!/bin/bash

set +e

echo "======================================"
echo "   Komari Agent 一键彻底清理脚本"
echo "======================================"
echo

SERVICE="komari-agent"
AGENT="/opt/komari/agent"

echo "[1/6] 停止 Komari Agent..."

systemctl stop ${SERVICE}.service 2>/dev/null
systemctl disable ${SERVICE}.service 2>/dev/null

echo "[2/6] 杀掉残留 Agent 进程..."

pkill -f "/opt/komari/agent" 2>/dev/null

sleep 1

echo "[3/6] 删除 systemd 服务..."

rm -f /etc/systemd/system/${SERVICE}.service
rm -f /etc/systemd/system/multi-user.target.wants/${SERVICE}.service

systemctl daemon-reload 2>/dev/null
systemctl reset-failed 2>/dev/null

echo "[4/6] 删除 Komari Agent 程序..."

rm -f "${AGENT}"

echo "[5/6] 检查 Agent 残留..."

echo

if systemctl cat ${SERVICE}.service >/dev/null 2>&1; then
    echo "❌ systemd 服务仍然存在"
else
    echo "✅ systemd 服务已删除"
fi

if pgrep -f "/opt/komari/agent" >/dev/null 2>&1; then
    echo "❌ Agent 进程仍然存在"
    pgrep -af "/opt/komari/agent"
else
    echo "✅ Agent 进程已停止"
fi

if [ -f "${AGENT}" ]; then
    echo "❌ Agent 文件仍然存在：${AGENT}"
else
    echo "✅ Agent 文件已删除"
fi

echo
echo "[6/6] 当前 /opt/komari 内容："

if [ -d /opt/komari ]; then
    ls -lah /opt/komari
else
    echo "/opt/komari 目录不存在"
fi

echo
echo "======================================"
echo " Komari Agent 清理完成"
echo "======================================"
echo
echo "下一步："
echo "1. 去 Komari 后台删除原来的服务器节点"
echo "2. 重新复制 Auto Discovery 安装命令"
echo "3. 在本机重新安装 Agent"
echo
echo "注意：本脚本不会删除 /opt/komari/komari 主控程序。"

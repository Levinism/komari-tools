# Komari Agent Cleanup Tool

用于彻底清理 Linux 服务器上的 Komari Agent，方便重新通过 **Auto Discovery** 注册到 Komari 面板。

适用于以下情况：

- 服务器以前安装过 Komari Agent
- 更换或重装了 Komari 主控
- Auto Discovery 一直返回 `401 Unauthorized`
- 日志中出现：

```text
Using existing auto-discovery token for UUID: ...
```

这通常是因为服务器本地还残留：

```text
/opt/komari/auto-discovery.json
```

该文件保存了旧的 UUID 和 Token。  
即使重新安装 Agent，也可能继续复用旧身份，导致新 Komari 主控返回：

```text
401 Unauthorized
```

---

## 一键清理

执行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Levinism/komari-tools/main/clean-komari-agent.sh)
```

---

## 脚本会做什么

脚本会执行以下操作：

- 停止 `komari-agent`
- 禁用 `komari-agent` 开机自启
- 结束残留 Agent 进程
- 删除 systemd 服务文件
- 删除 Komari Agent 程序
- 删除旧的 Auto Discovery 身份文件
- 重新加载 systemd
- 自动检查是否清理完成

主要清理以下内容：

```text
/etc/systemd/system/komari-agent.service
/etc/systemd/system/multi-user.target.wants/komari-agent.service
/opt/komari/agent
/opt/komari/auto-discovery.json
```

---

## 不会删除什么

本脚本不会删除 Komari Server 主控程序：

```text
/opt/komari/komari
```

因此，如果当前服务器同时运行 Komari Server 和 Komari Agent，脚本只会清理 Agent。

> 请不要直接执行：
>
> ```bash
> rm -rf /opt/komari
> ```
>
> 如果服务器同时运行 Komari 主控，这样可能会把主控程序一起删除。

---

## 推荐使用流程

### 1. 清理旧 Komari Agent

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Levinism/komari-tools/main/clean-komari-agent.sh)
```

### 2. 确认清理结果

正常情况下会看到类似：

```text
✅ systemd 服务已删除
✅ Agent 进程已清除
✅ Agent 程序已删除
✅ Auto Discovery 旧身份文件已删除
```

### 3. 打开 Komari 后台

进入服务器添加页面，复制新的 **Auto Discovery** 安装命令。

建议直接使用 Komari 后台自动生成的命令，不要手动修改 Key。



## 常见问题

### Auto Discovery 返回 401 Unauthorized

查看日志：

```bash
journalctl -u komari-agent -n 50 --no-pager
```

如果看到：

```text
Using existing auto-discovery token for UUID: ...
```

说明 Agent 正在复用以前保存的 Auto Discovery 身份。

重点检查：

```bash
ls -lah /opt/komari
```

确认不存在：

```text
agent
auto-discovery.json
```

尤其是：

```text
/opt/komari/auto-discovery.json
```

这个文件保存了旧 UUID 和 Token，是旧机器重新接入新 Komari 主控时常见的 `401 Unauthorized` 原因。

重新执行本仓库的一键清理脚本即可。

---

## 手动检查是否清理干净

### 检查 systemd 服务

```bash
systemctl cat komari-agent
```

清理成功通常会显示：

```text
No files found for komari-agent.service.
```

### 检查 Agent 进程

```bash
ps -ef | grep '/opt/komari/agent' | grep -v grep
```

正常情况下没有任何输出。

### 检查 Agent 文件

```bash
ls -l /opt/komari/agent
```

正常情况下会显示：

```text
No such file or directory
```

### 检查 Auto Discovery 身份文件

```bash
ls -l /opt/komari/auto-discovery.json
```

正常情况下同样会显示：

```text
No such file or directory
```

---

## 项目文件

```text
komari-tools/
├── README.md
└── clean-komari-agent.sh
```

---

---

## 说明

本工具主要用于处理：

```text
旧 Komari Agent
        ↓
残留 auto-discovery.json
        ↓
复用旧 UUID / Token
        ↓
新 Komari 主控返回 401 Unauthorized
```

清理后重新运行 Auto Discovery，即可让 Agent 获取新的身份信息并重新注册。

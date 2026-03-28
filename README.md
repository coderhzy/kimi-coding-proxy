# Kimi Coding Proxy

[English](#english) | [中文](#中文)

---

<a name="english"></a>

## 🚀 Kimi K2.5 Coding API Reverse Proxy

A lightweight reverse proxy that exposes [Kimi K2.5 Coding API](https://platform.moonshot.cn/) through a **standard OpenAI-compatible interface**, unlocking the full power of Kimi — chain-of-thought reasoning, function calling, vision, 256K context — for any client that speaks the OpenAI API format.

**Zero dependencies.** Single-file Node.js server. Works with [New API](https://github.com/Calcium-Ion/new-api), [OneAPI](https://github.com/songquanpeng/one-api), [ChatGPT-Next-Web](https://github.com/ChatGPTNextWeb/ChatGPT-Next-Web), and any OpenAI-compatible client.

### ✨ Features

- **🧠 Chain-of-Thought (Thinking)** — Kimi's `reasoning_content` automatically wrapped in `<think>` tags
- **🔧 Function Calling** — Single, parallel, and multi-turn tool calls; auto-fixes `reasoning_content` for assistant messages
- **🖼️ Vision** — Image URL auto-converted to Base64 (Kimi requires Base64); supports multi-image
- **🔑 Multi-Key Pool** — Round-robin load balancing with per-key RPM limiting
- **♻️ Auto Retry** — Failed requests retry on the next available key
- **🔒 Key Health** — 3 consecutive failures → key disabled for 5 min → auto-recovery
- **📊 Health Endpoint** — `GET /health` returns key status, request counts, and feature list
- **🧹 JSON Mode Cleanup** — Strips markdown fences from JSON-mode responses
- **📡 Telegram Alerts** — Optional notifications when keys fail or all keys go down
- **🔄 Hot Reload** — Config file changes detected and applied without restart
- **📦 Zero Dependencies** — Pure Node.js, no `npm install` required

### 📋 Capability Test Results

30 tests performed against the proxy. **26 passed, 1 partial, 3 unsupported.**

| # | Capability | Status | Notes |
|---|-----------|--------|-------|
| 1 | Basic Chat | ✅ | |
| 2 | Chain-of-Thought (Thinking) | ✅ | `reasoning_content` → `<think>` tags |
| 3 | Code Generation | ✅ | |
| 4 | Math Reasoning | ✅ | |
| 5 | Translation | ✅ | |
| 6 | Summarization | ✅ | |
| 7 | Creative Writing | ✅ | |
| 8 | Image URL → Base64 | ✅ | Auto-download & convert |
| 9 | Base64 Direct Pass | ✅ | |
| 10 | Multi-Image | ✅ | |
| 11 | Single Function Call | ✅ | |
| 12 | Parallel Function Calls | ✅ | |
| 13 | Tool Call Multi-Turn | ✅ | Auto-fills `reasoning_content` |
| 14 | Thinking + Tool Call Simultaneous | ✅ | |
| 15 | tool_choice=none | ✅ | |
| 16 | Multi-Turn Conversation | ✅ | |
| 17 | System Prompt | ✅ | |
| 18 | Role Play | ✅ | |
| 19 | Streaming Output | ✅ | |
| 20 | Streaming Function Call | ✅ | |
| 21 | Temperature | ✅ | |
| 22 | Top-P | ✅ | |
| 23 | Stop Sequences | ✅ | |
| 24 | Seed (Reproducible) | ✅ | |
| 25 | Usage Statistics | ✅ | |
| 26 | Long Context 256K | ✅ | |
| 27 | Streaming Thinking Tag Splicing | ⚠️ | Tags may split across chunks |
| 28 | tool_choice=specific tool | ❌ | Conflicts with `enable_thinking` |
| 29 | Presence/Frequency Penalty | ❌ | Kimi only allows value 0 |
| 30 | Video Understanding | ❌ | Not supported by Coding API |

### 🏁 Quick Start

#### Option 1: Direct Run

```bash
git clone https://github.com/YOUR_USERNAME/kimi-coding-proxy.git
cd kimi-coding-proxy
cp config.example.json config.json
# Edit config.json — add your Kimi API key(s)
node proxy.js
```

#### Option 2: Docker

```bash
git clone https://github.com/YOUR_USERNAME/kimi-coding-proxy.git
cd kimi-coding-proxy
cp config.example.json config.json
# Edit config.json — add your Kimi API key(s)
docker compose up -d
```

The proxy listens on `http://localhost:8919` by default.

### ⚙️ Configuration

Create `config.json` from the example:

```json
{
  "port": 8919,
  "target_host": "api.kimi.com",
  "target_path_prefix": "/coding",
  "coding_ua": "claude-cli/2.1.44 (external, sdk-cli)",
  "auto_thinking": true,
  "rate_limit_rpm": 30,
  "max_retries": 2,
  "keys": [
    { "key": "sk-kimi-your-key-here", "name": "main-key" },
    { "key": "sk-kimi-backup-key", "name": "backup-key" }
  ],
  "telegram": {
    "enabled": false,
    "bot_token": "YOUR_BOT_TOKEN",
    "chat_id": "YOUR_CHAT_ID"
  }
}
```

| Field | Description | Default |
|-------|-------------|---------|
| `port` | Listening port | `8919` |
| `target_host` | Kimi API host | `api.kimi.com` |
| `target_path_prefix` | API path prefix | `/coding` |
| `auto_thinking` | Auto-inject `enable_thinking: true` | `true` |
| `rate_limit_rpm` | Max requests per minute per key | `30` |
| `max_retries` | Retry count on failure | `2` |
| `keys` | Array of API keys (string or `{key, name}`) | `[]` |
| `telegram.enabled` | Enable Telegram alerts | `false` |

### 📡 API Usage

The proxy is fully OpenAI-compatible. Point any client at `http://localhost:8919`.

#### Basic Chat

```bash
curl http://localhost:8919/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kimi-k2-0711",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

#### Streaming with Thinking

```bash
curl http://localhost:8919/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kimi-k2-0711",
    "stream": true,
    "messages": [{"role": "user", "content": "Solve: what is 127 * 389?"}]
  }'
```

Response includes `<think>...</think>` tags wrapping the reasoning process.

#### Function Calling

```bash
curl http://localhost:8919/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kimi-k2-0711",
    "messages": [{"role": "user", "content": "What is the weather in Beijing?"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get weather for a city",
        "parameters": {
          "type": "object",
          "properties": { "city": { "type": "string" } },
          "required": ["city"]
        }
      }
    }]
  }'
```

#### Vision (Image URL)

```bash
curl http://localhost:8919/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kimi-k2-0711",
    "messages": [{
      "role": "user",
      "content": [
        {"type": "text", "text": "What is in this image?"},
        {"type": "image_url", "image_url": {"url": "https://example.com/photo.jpg"}}
      ]
    }]
  }'
```

The proxy automatically downloads the image and converts it to Base64.

### 🔗 Integration with New API / OneAPI

Add as a custom OpenAI-compatible channel:

| Setting | Value |
|---------|-------|
| **Type** | OpenAI |
| **Base URL** | `http://your-server:8919` |
| **API Key** | Any non-empty string (proxy ignores incoming keys) |
| **Model** | `kimi-k2-0711` |

### 🏗️ Architecture

```
Client (OpenAI format)
    │
    ▼
┌──────────────────────────┐
│   Kimi Coding Proxy      │
│                          │
│  ┌─────────────────────┐ │
│  │ Request Parser      │ │
│  │ - Parse OpenAI body │ │
│  │ - Auto-inject       │ │
│  │   enable_thinking   │ │
│  │ - Fix tool_calls    │ │
│  │   reasoning_content │ │
│  └────────┬────────────┘ │
│           │              │
│  ┌────────▼────────────┐ │
│  │ Image Processor     │ │
│  │ - Detect image URLs │ │
│  │ - Download & Base64 │ │
│  └────────┬────────────┘ │
│           │              │
│  ┌────────▼────────────┐ │
│  │ Key Pool Manager    │ │
│  │ - Round-robin       │ │
│  │ - RPM limiting      │ │
│  │ - Health tracking   │ │
│  │ - Auto-recovery     │ │
│  └────────┬────────────┘ │
│           │              │
│  ┌────────▼────────────┐ │
│  │ Response Transform  │ │
│  │ - reasoning_content │ │
│  │   → <think> tags    │ │
│  │ - JSON mode cleanup │ │
│  │ - Stream processing │ │
│  └─────────────────────┘ │
│                          │
│  ┌─────────────────────┐ │
│  │ Telegram Alerting   │ │
│  └─────────────────────┘ │
└──────────────┬───────────┘
               │
               ▼
        Kimi Coding API
       (api.kimi.com/coding)
```

### 📊 Health Check

```bash
curl http://localhost:8919/health
```

Returns JSON with status, key pool details, and feature list.

---

<a name="中文"></a>

## 🚀 Kimi K2.5 Coding API 反向代理

一个轻量级反向代理，将 [Kimi K2.5 Coding API](https://platform.moonshot.cn/) 以**标准 OpenAI 兼容格式**暴露，解锁 Kimi 的全部能力——思考链推理、Function Call、图片理解、256K 上下文——适用于任何兼容 OpenAI API 格式的客户端。

**零依赖。** 单文件 Node.js 服务。可无缝对接 [New API](https://github.com/Calcium-Ion/new-api)、[OneAPI](https://github.com/songquanpeng/one-api)、[ChatGPT-Next-Web](https://github.com/ChatGPTNextWeb/ChatGPT-Next-Web) 以及任何 OpenAI 兼容客户端。

### ✨ 功能特性

- **🧠 思考链（Thinking）** — Kimi 的 `reasoning_content` 自动包裹在 `<think>` 标签中
- **🔧 Function Call** — 支持单次、并行、多轮工具调用；自动修复 assistant 消息的 `reasoning_content`
- **🖼️ 图片理解** — 图片 URL 自动下载转 Base64（Kimi 要求 Base64 格式）；支持多图
- **🔑 多 Key 池** — 轮询负载均衡，每个 Key 独立 RPM 限流
- **♻️ 自动重试** — 请求失败自动切换到下一个可用 Key 重试
- **🔒 Key 健康管理** — 连续 3 次失败 → 禁用 5 分钟 → 自动恢复
- **📊 健康检查** — `GET /health` 返回 Key 状态、请求计数和功能列表
- **🧹 JSON 模式清理** — 自动去除 JSON 模式响应中的 markdown 代码块标记
- **📡 Telegram 告警** — Key 异常或全部不可用时可选发送 Telegram 通知
- **🔄 热重载** — 配置文件变更自动检测，无需重启
- **📦 零依赖** — 纯 Node.js 实现，无需 `npm install`

### 📋 能力测试结果

共 30 项测试。**26 项通过，1 项部分支持，3 项不支持。**

| # | 能力 | 状态 | 备注 |
|---|------|------|------|
| 1 | 基础对话 | ✅ | |
| 2 | 思考链（Thinking） | ✅ | `reasoning_content` → `<think>` 标签 |
| 3 | 代码生成 | ✅ | |
| 4 | 数学推理 | ✅ | |
| 5 | 翻译 | ✅ | |
| 6 | 摘要 | ✅ | |
| 7 | 创意写作 | ✅ | |
| 8 | 图片 URL 转 Base64 | ✅ | 自动下载转换 |
| 9 | Base64 直传 | ✅ | |
| 10 | 多图理解 | ✅ | |
| 11 | 单次 Function Call | ✅ | |
| 12 | 并行 Function Call | ✅ | |
| 13 | Tool Call 多轮对话 | ✅ | 自动补全 `reasoning_content` |
| 14 | 思考链 + Tool Call 同时 | ✅ | |
| 15 | tool_choice=none | ✅ | |
| 16 | 多轮对话 | ✅ | |
| 17 | System Prompt | ✅ | |
| 18 | 角色扮演 | ✅ | |
| 19 | 流式输出 | ✅ | |
| 20 | 流式 Function Call | ✅ | |
| 21 | Temperature 参数 | ✅ | |
| 22 | Top-P 参数 | ✅ | |
| 23 | Stop 序列 | ✅ | |
| 24 | Seed 可复现 | ✅ | |
| 25 | Usage 统计 | ✅ | |
| 26 | 长上下文 256K | ✅ | |
| 27 | 流式思考链标签拼接 | ⚠️ | 标签可能跨 chunk 拆分 |
| 28 | tool_choice 指定工具 | ❌ | 与 `enable_thinking` 冲突 |
| 29 | Presence/Frequency Penalty | ❌ | Kimi 仅允许值为 0 |
| 30 | 视频理解 | ❌ | Coding API 不支持 |

### 🏁 快速开始

#### 方式一：直接运行

```bash
git clone https://github.com/YOUR_USERNAME/kimi-coding-proxy.git
cd kimi-coding-proxy
cp config.example.json config.json
# 编辑 config.json —— 填入你的 Kimi API Key
node proxy.js
```

#### 方式二：Docker

```bash
git clone https://github.com/YOUR_USERNAME/kimi-coding-proxy.git
cd kimi-coding-proxy
cp config.example.json config.json
# 编辑 config.json —— 填入你的 Kimi API Key
docker compose up -d
```

代理默认监听 `http://localhost:8919`。

### ⚙️ 配置说明

从示例文件创建 `config.json`：

```json
{
  "port": 8919,
  "target_host": "api.kimi.com",
  "target_path_prefix": "/coding",
  "coding_ua": "claude-cli/2.1.44 (external, sdk-cli)",
  "auto_thinking": true,
  "rate_limit_rpm": 30,
  "max_retries": 2,
  "keys": [
    { "key": "sk-kimi-your-key-here", "name": "main-key" },
    { "key": "sk-kimi-backup-key", "name": "backup-key" }
  ],
  "telegram": {
    "enabled": false,
    "bot_token": "YOUR_BOT_TOKEN",
    "chat_id": "YOUR_CHAT_ID"
  }
}
```

| 字段 | 说明 | 默认值 |
|------|------|--------|
| `port` | 监听端口 | `8919` |
| `target_host` | Kimi API 地址 | `api.kimi.com` |
| `target_path_prefix` | API 路径前缀 | `/coding` |
| `auto_thinking` | 自动注入 `enable_thinking: true` | `true` |
| `rate_limit_rpm` | 每个 Key 每分钟最大请求数 | `30` |
| `max_retries` | 失败重试次数 | `2` |
| `keys` | API Key 数组（字符串或 `{key, name}` 对象） | `[]` |
| `telegram.enabled` | 启用 Telegram 告警 | `false` |

### 📡 API 使用示例

代理完全兼容 OpenAI 格式。将客户端指向 `http://localhost:8919` 即可。

#### 基础对话

```bash
curl http://localhost:8919/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kimi-k2-0711",
    "messages": [{"role": "user", "content": "你好！"}]
  }'
```

#### 流式输出 + 思考链

```bash
curl http://localhost:8919/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kimi-k2-0711",
    "stream": true,
    "messages": [{"role": "user", "content": "计算 127 × 389 = ?"}]
  }'
```

响应中包含 `<think>...</think>` 标签包裹的推理过程。

#### Function Call

```bash
curl http://localhost:8919/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kimi-k2-0711",
    "messages": [{"role": "user", "content": "北京今天天气怎么样？"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "获取城市天气",
        "parameters": {
          "type": "object",
          "properties": { "city": { "type": "string" } },
          "required": ["city"]
        }
      }
    }]
  }'
```

#### 图片理解

```bash
curl http://localhost:8919/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kimi-k2-0711",
    "messages": [{
      "role": "user",
      "content": [
        {"type": "text", "text": "这张图片里有什么？"},
        {"type": "image_url", "image_url": {"url": "https://example.com/photo.jpg"}}
      ]
    }]
  }'
```

代理会自动下载图片并转换为 Base64 格式。

### 🔗 对接 New API / OneAPI

添加为自定义 OpenAI 兼容渠道：

| 设置 | 值 |
|------|----|
| **类型** | OpenAI |
| **Base URL** | `http://your-server:8919` |
| **API Key** | 任意非空字符串（代理忽略传入的 Key） |
| **模型** | `kimi-k2-0711` |

### 🏗️ 架构说明

```
客户端（OpenAI 格式）
    │
    ▼
┌──────────────────────────┐
│   Kimi Coding Proxy      │
│                          │
│  ┌─────────────────────┐ │
│  │ 请求解析            │ │
│  │ - 解析 OpenAI 请求体│ │
│  │ - 自动注入          │ │
│  │   enable_thinking   │ │
│  │ - 修复 tool_calls   │ │
│  │   reasoning_content │ │
│  └────────┬────────────┘ │
│           │              │
│  ┌────────▼────────────┐ │
│  │ 图片处理器          │ │
│  │ - 检测图片 URL      │ │
│  │ - 下载转 Base64     │ │
│  └────────┬────────────┘ │
│           │              │
│  ┌────────▼────────────┐ │
│  │ Key 池管理器        │ │
│  │ - 轮询调度          │ │
│  │ - RPM 限流          │ │
│  │ - 健康追踪          │ │
│  │ - 自动恢复          │ │
│  └────────┬────────────┘ │
│           │              │
│  ┌────────▼────────────┐ │
│  │ 响应转换            │ │
│  │ - reasoning_content │ │
│  │   → <think> 标签    │ │
│  │ - JSON 模式清理     │ │
│  │ - 流式处理          │ │
│  └─────────────────────┘ │
│                          │
│  ┌─────────────────────┐ │
│  │ Telegram 告警       │ │
│  └─────────────────────┘ │
└──────────────┬───────────┘
               │
               ▼
        Kimi Coding API
       (api.kimi.com/coding)
```

### 📊 健康检查

```bash
curl http://localhost:8919/health
```

返回 JSON 格式的状态信息，包括 Key 池详情和功能列表。

---

## 📄 License

[MIT](LICENSE)

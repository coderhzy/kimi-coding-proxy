# Kimi Coding Proxy

**[English](README.md)** | **[中文文档](README_CN.md)**

---
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
git clone https://github.com/coderhzy/kimi-coding-proxy.git
cd kimi-coding-proxy
cp config.example.json config.json
# Edit config.json — add your Kimi API key(s)
node proxy.js
```

#### Option 2: Docker

```bash
git clone https://github.com/coderhzy/kimi-coding-proxy.git
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
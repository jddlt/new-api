# New API 完整接口文档

## 📋 项目概述

New API 是一个基于 Go 语言开发的AI模型API网关与资产管理系统，支持多种AI模型的统一调用和管理。

- **项目版本**: v0.0.0
- **技术栈**: Go + Gin + GORM + MySQL/Redis
- **认证方式**: Session + Access Token + API Key
- **支持数据库**: MySQL, PostgreSQL, SQLite

---

## 🔐 认证机制

### 1. Session认证
- **Cookie名称**: `session`
- **Domain**: `.mrpzx.cn` (支持跨子域)
- **过期时间**: 30天

<!-- ### 2. Access Token认证
- **格式**: `Authorization: Bearer <token>`
- **获取方式**: `GET /api/user/token`

### 3. API Key认证
- **格式**: `Authorization: Bearer sk-<key>`
- **适用接口**: AI模型调用接口 -->

---

## 🚀 管理API接口 (/api)

### 系统相关

#### 1. 获取系统状态
```http
GET /api/status
```

**认证**: 无需认证
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": {
    "version": "v0.0.0",
    "start_time": 1640995200,
    "system_name": "New API"
  }
}
```

#### 2. 获取系统信息
```http
GET /api/about
```

**认证**: 无需认证
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": {
    "version": "v0.0.0",
    "system_name": "New API",
    "footer": "",
    "logo": ""
  }
}
```

#### 3. 获取公告
```http
GET /api/notice
```

**认证**: 无需认证
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": "系统公告内容"
}
```

#### 4. 获取首页内容
```http
GET /api/home_page_content
```

**认证**: 无需认证
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": {
    "content": "首页内容"
  }
}
```

### 用户管理

#### 5. 用户注册
```http
POST /api/user/register
Content-Type: application/json
```

**认证**: 无需认证
**请求参数**:
```json
{
  "username": "string (必填)",
  "password": "string (必填, 8-20字符)",
  "email": "string (可选)",
  "aff_code": "string (可选, 邀请码)"
}
```

**响应**:
```json
{
  "success": true,
  "message": "注册成功"
}
```

**错误响应**:
```json
{
  "success": false,
  "message": "用户名已存在"
}
```

#### 6. 用户登录
```http
POST /api/user/login
Content-Type: application/json
```

**认证**: 无需认证
**请求参数**:
```json
{
  "username": "string (必填)",
  "password": "string (必填)"
}
```

**响应**:
```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "id": 1,
    "username": "testuser",
    "role": 1,
    "group": "default"
  }
}
```

#### 7. 获取用户信息
```http
GET /api/user/self
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": {
    "id": 1,
    "username": "testuser",
    "display_name": "Test User",
    "email": "test@example.com",
    "role": 1,
    "status": 1,
    "quota": 1000,
    "used_quota": 100,
    "group": "default",
    "aff_code": "ABC123"
  }
}
```

#### 8. 更新用户信息
```http
PUT /api/user/self
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**请求参数**:
```json
{
  "display_name": "新显示名称",
  "email": "newemail@example.com"
}
```

**响应**:
```json
{
  "success": true,
  "message": "用户信息更新成功"
}
```

#### 9. 删除用户
```http
DELETE /api/user/self
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**响应**:
```json
{
  "success": true,
  "message": "用户删除成功"
}
```

#### 10. 生成Access Token
```http
GET /api/user/token
Authorization: Bearer <session_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: Session
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": "32位access_token字符串"
}
```

#### 11. 获取用户模型列表
```http
GET /api/user/models
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": [
    "gpt-4",
    "gpt-3.5-turbo",
    "claude-3-sonnet-20240229"
  ]
}
```

#### 12. 获取用户分组
```http
GET /api/user/groups
```

**认证**: 无需认证
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": ["default", "vip", "premium"]
}
```

### Token管理

#### 13. 获取Token列表
```http
GET /api/token
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**查询参数**:
- `p`: 页码 (默认1)
- `size`: 每页数量 (默认10)

**响应**:
```json
{
  "success": true,
  "message": "",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "name": "默认Token",
      "status": 1,
      "created_time": 1640995200,
      "expired_time": -1,
      "remain_quota": 1000,
      "unlimited_quota": false,
      "used_quota": 100,
      "group": "default"
    }
  ]
}
```

#### 14. 创建Token
```http
POST /api/token
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**请求参数**:
```json
{
  "name": "我的Token",
  "remain_quota": 1000,
  "unlimited_quota": false,
  "expired_time": -1,
  "group": "default"
}
```

**响应**:
```json
{
  "success": true,
  "message": "Token创建成功",
  "data": {
    "id": 1,
    "key": "sk-abcdef1234567890",
    "name": "我的Token"
  }
}
```

#### 15. 更新Token
```http
PUT /api/token
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**请求参数**:
```json
{
  "id": 1,
  "name": "更新的Token名称",
  "status": 1,
  "remain_quota": 500
}
```

**响应**:
```json
{
  "success": true,
  "message": "Token更新成功"
}
```

#### 16. 删除Token
```http
DELETE /api/token/:id
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**响应**:
```json
{
  "success": true,
  "message": "Token删除成功"
}
```

#### 17. 批量删除Token
```http
POST /api/token/batch
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**请求参数**:
```json
{
  "ids": [1, 2, 3]
}
```

**响应**:
```json
{
  "success": true,
  "message": "成功删除 3 个Token"
}
```

### 渠道管理 (管理员权限)

#### 18. 获取渠道列表
```http
GET /api/channel
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**查询参数**:
- `p`: 页码
- `size`: 每页数量

**响应**:
```json
{
  "success": true,
  "message": "",
  "data": [
    {
      "id": 1,
      "type": 1,
      "name": "OpenAI渠道",
      "status": 1,
      "created_time": 1640995200,
      "test_time": 1640995200,
      "response_time": 1000,
      "base_url": "",
      "models": "gpt-4,gpt-3.5-turbo",
      "group": "default",
      "used_quota": 1000,
      "priority": 0,
      "tag": "openai"
    }
  ]
}
```

#### 19. 添加渠道
```http
POST /api/channel
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**请求参数**:
```json
{
  "name": "新渠道",
  "type": 1,
  "key": "sk-your-api-key",
  "base_url": "",
  "models": "gpt-4,gpt-3.5-turbo",
  "group": "default",
  "status": 1
}
```

**响应**:
```json
{
  "success": true,
  "message": "渠道添加成功",
  "data": {
    "id": 1,
    "name": "新渠道"
  }
}
```

#### 20. 更新渠道
```http
PUT /api/channel
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**请求参数**:
```json
{
  "id": 1,
  "name": "更新的渠道名称",
  "status": 1,
  "models": "gpt-4,gpt-3.5-turbo,claude-3"
}
```

**响应**:
```json
{
  "success": true,
  "message": "渠道更新成功"
}
```

#### 21. 删除渠道
```http
DELETE /api/channel/:id
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**响应**:
```json
{
  "success": true,
  "message": "渠道删除成功"
}
```

#### 22. 测试渠道
```http
GET /api/channel/test/:id
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**查询参数**:
- `model`: 测试的模型名称

**响应**:
```json
{
  "success": true,
  "message": "渠道测试成功",
  "data": {
    "response_time": 1200,
    "status": "success"
  }
}
```

#### 23. 批量测试渠道
```http
GET /api/channel/test
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**响应**:
```json
{
  "success": true,
  "message": "开始批量测试渠道"
}
```

### 日志管理

#### 24. 获取用户日志
```http
GET /api/log/self
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**查询参数**:
- `p`: 页码
- `size`: 每页数量
- `type`: 日志类型 (可选)

**响应**:
```json
{
  "success": true,
  "message": "",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "created_at": 1640995200,
      "type": 1,
      "content": "用户消费",
      "username": "testuser",
      "token_name": "默认Token",
      "model_name": "gpt-4",
      "quota": 100,
      "prompt_tokens": 10,
      "completion_tokens": 20,
      "channel_id": 1,
      "token_id": 1,
      "group": "default"
    }
  ]
}
```

#### 25. 获取所有日志 (管理员)
```http
GET /api/log
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**查询参数**:
- `p`: 页码
- `size`: 每页数量
- `type`: 日志类型
- `username`: 用户名
- `model_name`: 模型名称
- `start_timestamp`: 开始时间
- `end_timestamp`: 结束时间

**响应**: 同上

### 兑换码管理 (管理员权限)

#### 26. 获取兑换码列表
```http
GET /api/redemption
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": [
    {
      "id": 1,
      "name": "新人礼包",
      "key": "WELCOME2024",
      "created_time": 1640995200,
      "quota": 1000,
      "count": 100,
      "used_count": 10,
      "status": 1
    }
  ]
}
```

#### 27. 创建兑换码
```http
POST /api/redemption
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**请求参数**:
```json
{
  "name": "活动兑换码",
  "quota": 500,
  "count": 50
}
```

**响应**:
```json
{
  "success": true,
  "message": "兑换码创建成功",
  "data": {
    "id": 1,
    "key": "ABC123DEF456"
  }
}
```

### 数据统计

#### 28. 获取用户数据统计
```http
GET /api/data/self
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: Session 或 Access Token
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": [
    {
      "date": "2024-01-01",
      "quota": 1000,
      "used_quota": 500,
      "request_count": 50
    }
  ]
}
```

#### 29. 获取所有数据统计 (管理员)
```http
GET /api/data
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**响应**: 同上

---

## 🤖 AI模型调用API

### OpenAI兼容接口 (/v1)

#### 30. 模型列表
```http
GET /v1/models
Authorization: Bearer sk-<your-api-key>
```

**认证**: API Key
**响应**:
```json
{
  "object": "list",
  "data": [
    {
      "id": "gpt-4",
      "object": "model",
      "created": 1640995200,
      "owned_by": "openai"
    }
  ]
}
```

#### 31. 模型信息
```http
GET /v1/models/:model
Authorization: Bearer sk-<your-api-key>
```

**认证**: API Key
**响应**:
```json
{
  "id": "gpt-4",
  "object": "model",
  "created": 1640995200,
  "owned_by": "openai"
}
```

#### 32. 聊天完成
```http
POST /v1/chat/completions
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "user",
      "content": "你好，请介绍一下自己"
    }
  ],
  "max_tokens": 1000,
  "temperature": 0.7,
  "stream": false
}
```

**响应**:
```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1640995200,
  "model": "gpt-4",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "我是AI助手..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 20,
    "total_tokens": 30
  }
}
```

#### 33. 文本完成
```http
POST /v1/completions
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "model": "gpt-3.5-turbo-instruct",
  "prompt": "请写一首诗",
  "max_tokens": 100,
  "temperature": 0.8
}
```

**响应**:
```json
{
  "id": "cmpl-123",
  "object": "text_completion",
  "created": 1640995200,
  "model": "gpt-3.5-turbo-instruct",
  "choices": [
    {
      "text": "诗的内容...",
      "index": 0,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 5,
    "completion_tokens": 50,
    "total_tokens": 55
  }
}
```

#### 34. 图像生成
```http
POST /v1/images/generations
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "model": "dall-e-3",
  "prompt": "一只可爱的小猫",
  "size": "1024x1024",
  "quality": "standard",
  "n": 1
}
```

**响应**:
```json
{
  "created": 1640995200,
  "data": [
    {
      "url": "https://example.com/image.png",
      "revised_prompt": "A cute little cat sitting on a windowsill"
    }
  ]
}
```

#### 35. 图像编辑
```http
POST /v1/images/edits
Authorization: Bearer sk-<your-api-key>
Content-Type: multipart/form-data
```

**认证**: API Key
**请求参数**:
- `image`: 图片文件
- `mask`: 蒙版文件 (可选)
- `prompt`: 编辑提示词
- `size`: 图片尺寸

**响应**: 同图像生成

#### 36. 图像变体
```http
POST /v1/images/variations
Authorization: Bearer sk-<your-api-key>
Content-Type: multipart/form-data
```

**认证**: API Key
**请求参数**:
- `image`: 图片文件
- `size`: 图片尺寸
- `n`: 生成数量

**响应**: 同图像生成

#### 37. 嵌入向量
```http
POST /v1/embeddings
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "model": "text-embedding-ada-002",
  "input": "要嵌入的文本内容",
  "user": "user123"
}
```

**响应**:
```json
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "embedding": [0.1, 0.2, 0.3, ...],
      "index": 0
    }
  ],
  "model": "text-embedding-ada-002",
  "usage": {
    "prompt_tokens": 8,
    "total_tokens": 8
  }
}
```

#### 38. 音频转录
```http
POST /v1/audio/transcriptions
Authorization: Bearer sk-<your-api-key>
Content-Type: multipart/form-data
```

**认证**: API Key
**请求参数**:
- `file`: 音频文件
- `model`: "whisper-1"
- `language`: 语言代码 (可选)

**响应**:
```json
{
  "text": "转录的文本内容"
}
```

#### 39. 音频翻译
```http
POST /v1/audio/translations
Authorization: Bearer sk-<your-api-key>
Content-Type: multipart/form-data
```

**认证**: API Key
**请求参数**:
- `file`: 音频文件
- `model`: "whisper-1"

**响应**:
```json
{
  "text": "翻译后的文本内容"
}
```

#### 40. 语音合成
```http
POST /v1/audio/speech
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "model": "tts-1",
  "input": "要合成的文本内容",
  "voice": "alloy",
  "response_format": "mp3"
}
```

**响应**: 音频文件流

#### 41. 实时对话 (WebSocket)
```http
GET /v1/realtime
Sec-WebSocket-Protocol: openai-insecure-api-key.sk-<your-api-key>, openai-beta.realtime-v1
```

**认证**: API Key (通过WebSocket协议头)
**WebSocket消息格式**:
```json
{
  "type": "session.update",
  "session": {
    "modalities": ["text", "audio"],
    "instructions": "You are a helpful assistant.",
    "voice": "alloy",
    "input_audio_format": "pcm16",
    "output_audio_format": "pcm16"
  }
}
```

#### 42. 审核内容
```http
POST /v1/moderations
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "input": "要审核的文本内容"
}
```

**响应**:
```json
{
  "id": "modr-123",
  "model": "text-moderation-latest",
  "results": [
    {
      "flagged": false,
      "categories": {
        "sexual": false,
        "hate": false,
        "violence": false
      },
      "category_scores": {
        "sexual": 0.001,
        "hate": 0.002,
        "violence": 0.003
      }
    }
  ]
}
```

### Claude接口 (/v1)

#### 43. Claude聊天
```http
POST /v1/messages
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "model": "claude-3-sonnet-20240229",
  "max_tokens": 1000,
  "messages": [
    {
      "role": "user",
      "content": "你好，请介绍一下自己"
    }
  ]
}
```

**响应**:
```json
{
  "id": "msg_123",
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "我是Claude，由Anthropic开发的AI助手..."
    }
  ],
  "model": "claude-3-sonnet-20240229",
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 10,
    "output_tokens": 20
  }
}
```

### Midjourney接口 (/mj)

#### 44. 提交Imagine任务
```http
POST /mj/submit/imagine
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "prompt": "A beautiful landscape with mountains and lake",
  "aspect": "16:9"
}
```

**响应**:
```json
{
  "success": true,
  "message": "任务提交成功",
  "data": {
    "task_id": "123456789",
    "status": "pending"
  }
}
```

#### 45. 获取任务状态
```http
GET /mj/task/:id/fetch
Authorization: Bearer sk-<your-api-key>
```

**认证**: API Key
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": {
    "task_id": "123456789",
    "status": "finished",
    "progress": "100%",
    "image_url": "https://example.com/image.png",
    "created_at": 1640995200
  }
}
```

#### 46. 提交Change任务
```http
POST /mj/submit/change
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "content": "U1",
  "action": "UPSCALE",
  "taskId": "123456789"
}
```

**响应**: 同Imagine任务

### Suno音乐生成接口 (/suno)

#### 47. 提交音乐生成任务
```http
POST /suno/submit/music
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "prompt": "A happy pop song about summer",
  "style": "pop",
  "duration": 30
}
```

**响应**:
```json
{
  "success": true,
  "message": "音乐生成任务提交成功",
  "data": {
    "task_id": "music_123",
    "status": "pending"
  }
}
```

#### 48. 获取音乐任务状态
```http
GET /suno/fetch/:id
Authorization: Bearer sk-<your-api-key>
```

**认证**: API Key
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": {
    "task_id": "music_123",
    "status": "finished",
    "audio_url": "https://example.com/music.mp3",
    "title": "Summer Pop Song",
    "duration": 30
  }
}
```

### Gemini接口 (/v1beta)

#### 49. Gemini模型调用
```http
POST /v1beta/models/gemini-pro:generateContent
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "contents": [
    {
      "parts": [
        {
          "text": "你好，请介绍一下自己"
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 1000
  }
}
```

**响应**:
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "我是Gemini，由Google开发的AI助手..."
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 5,
    "candidatesTokenCount": 20,
    "totalTokenCount": 25
  }
}
```

### 视频生成接口 (/v1)

#### 50. 视频生成
```http
POST /v1/video/generations
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "model": "video-generation",
  "prompt": "A beautiful sunset over the ocean",
  "duration": 5,
  "aspect_ratio": "16:9"
}
```

**响应**:
```json
{
  "success": true,
  "message": "视频生成任务提交成功",
  "data": {
    "task_id": "video_123",
    "status": "pending",
    "estimated_time": 300
  }
}
```

#### 51. 获取视频任务状态
```http
GET /v1/video/generations/:task_id
Authorization: Bearer sk-<your-api-key>
```

**认证**: API Key
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": {
    "task_id": "video_123",
    "status": "finished",
    "progress": "100%",
    "video_url": "https://example.com/video.mp4",
    "duration": 5,
    "created_at": 1640995200
  }
}
```

### Kling AI视频接口 (/kling/v1)

#### 52. 文本到视频
```http
POST /kling/v1/videos/text2video
Authorization: Bearer sk-<your-api-key>
Content-Type: application/json
```

**认证**: API Key
**请求参数**:
```json
{
  "model": "kling-v1",
  "prompt": "A cat playing in the garden",
  "duration": 5,
  "aspect_ratio": "16:9"
}
```

**响应**: 同视频生成接口

#### 53. 图像到视频
```http
POST /kling/v1/videos/image2video
Authorization: Bearer sk-<your-api-key>
Content-Type: multipart/form-data
```

**认证**: API Key
**请求参数**:
- `image`: 图片文件
- `prompt`: 视频描述
- `duration`: 视频时长

**响应**: 同视频生成接口

---

## 💰 计费相关API

### 仪表板API

#### 54. 获取订阅信息
```http
GET /dashboard/billing/subscription
Authorization: Bearer sk-<your-api-key>
```

**认证**: API Key
**响应**:
```json
{
  "object": "billing.subscription",
  "has_payment_method": true,
  "canceled": false,
  "canceled_at": null,
  "current_period_start": 1640995200,
  "current_period_end": 1643673600,
  "status": "active",
  "plan": {
    "id": "plan_123",
    "name": "Pro Plan",
    "price": 20
  }
}
```

#### 55. 获取使用统计
```http
GET /dashboard/billing/usage
Authorization: Bearer sk-<your-api-key>
```

**认证**: API Key
**响应**:
```json
{
  "object": "billing.usage",
  "total_usage": 1500,
  "daily_costs": [
    {
      "date": "2024-01-01",
      "cost": 5.50
    }
  ],
  "models_usage": [
    {
      "model": "gpt-4",
      "usage": 1000,
      "cost": 20.00
    }
  ]
}
```

---

## 🔧 系统管理API (超级管理员权限)

### 系统配置

#### 56. 获取系统选项
```http
GET /api/option
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 超级管理员权限
**响应**:
```json
{
  "success": true,
  "message": "",
  "data": {
    "system_name": "New API",
    "logo": "/logo.png",
    "footer": "© 2024 New API",
    "top_up_link": "https://pay.example.com",
    "chat_link": "https://chat.example.com"
  }
}
```

#### 57. 更新系统选项
```http
PUT /api/option
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: 超级管理员权限
**请求参数**:
```json
{
  "system_name": "New API Pro",
  "logo": "/new-logo.png"
}
```

**响应**:
```json
{
  "success": true,
  "message": "系统选项更新成功"
}
```

### 用户管理 (管理员权限)

#### 58. 获取所有用户
```http
GET /api/user
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**查询参数**:
- `p`: 页码
- `page_size`: 每页数量
- `username`: 用户名筛选
- `group`: 分组筛选

**响应**:
```json
{
  "success": true,
  "message": "",
  "data": [
    {
      "id": 1,
      "username": "testuser",
      "email": "test@example.com",
      "role": 1,
      "status": 1,
      "quota": 1000,
      "used_quota": 500,
      "group": "default",
      "created_at": 1640995200
    }
  ],
  "total": 100
}
```

#### 59. 创建用户
```http
POST /api/user
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**请求参数**:
```json
{
  "username": "newuser",
  "password": "password123",
  "email": "newuser@example.com",
  "role": 1,
  "quota": 1000,
  "group": "default"
}
```

**响应**:
```json
{
  "success": true,
  "message": "用户创建成功",
  "data": {
    "id": 2,
    "username": "newuser"
  }
}
```

#### 60. 更新用户
```http
PUT /api/user
Authorization: Bearer <access_token>
Content-Type: application/json
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**请求参数**:
```json
{
  "id": 2,
  "username": "updateduser",
  "quota": 2000,
  "status": 1
}
```

**响应**:
```json
{
  "success": true,
  "message": "用户更新成功"
}
```

#### 61. 删除用户
```http
DELETE /api/user/:id
Authorization: Bearer <access_token>
Headers:
  New-Api-User: <user_id>
```

**认证**: 管理员权限
**响应**:
```json
{
  "success": true,
  "message": "用户删除成功"
}
```

---

## 📊 错误码说明

### 通用错误响应格式
```json
{
  "success": false,
  "message": "错误描述"
}
```

### HTTP状态码
- `200`: 成功
- `400`: 请求参数错误
- `401`: 未认证/认证失败
- `403`: 权限不足
- `404`: 资源不存在
- `429`: 请求过于频繁
- `500`: 服务器内部错误

### 业务错误码
- `用户名已存在`: 用户注册时用户名重复
- `邮箱已被注册`: 用户注册时邮箱重复
- `密码错误`: 用户登录密码不正确
- `用户已被封禁`: 用户状态为禁用
- `配额不足`: 用户可用额度不足
- `Token无效`: API Key不存在或已过期
- `渠道不可用`: AI渠道状态异常

---

## 🔒 权限说明

### 用户角色等级
- **普通用户 (Role: 1)**: 基本的API调用和管理权限
- **管理员用户 (Role: 10)**: 用户管理、渠道管理等权限
- **超级管理员 (Role: 100)**: 系统配置、所有管理权限

### API权限要求
- **无需认证**: 系统状态、公告等公开接口
- **用户认证**: Token管理、个人数据等
- **管理员权限**: 用户管理、渠道管理等
- **超级管理员**: 系统配置、全局设置等

---

**文档版本**: 1.0
**最后更新**: 2024年12月
**API总数**: 61个
**维护者**: New API Team

此文档涵盖了New API系统的完整接口规范，包含详细的请求参数、响应格式和错误处理说明。如有疑问，请参考源码或提交Issue。

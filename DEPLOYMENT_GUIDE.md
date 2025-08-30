# Go代码部署指南

## 📋 修改总结

本次修改的文件：
1. **`main.go`** - Session配置，添加Domain支持跨域
2. **`router/api-router.go`** - 清理跨域相关路由

## 🚀 部署步骤

### 步骤1：验证修改

```bash
# 确认修改的文件
cd /Users/mrpzx/Documents/TestSpace/new-api

# 查看main.go的Session配置修改
grep -A 5 -B 5 "Domain.*mrpzx" main.go

# 查看路由清理情况
grep -n "validate_token\|refresh_token" router/api-router.go || echo "路由已清理完成"
```

### 步骤2：编译Go程序

```bash
# 方式1：使用Docker重新构建
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 方式2：直接编译Go程序
# 安装Go环境 (如果没有)
# wget https://golang.org/dl/go1.21.5.linux-amd64.tar.gz
# sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
# export PATH=$PATH:/usr/local/go/bin

# 设置Go环境变量
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct

# 下载依赖
go mod tidy
go mod download

# 编译程序
go build -o new-api main.go

# 交叉编译 (如果需要)
# GOOS=linux GOARCH=amd64 go build -o new-api-linux main.go
```

### 步骤3：停止现有服务

```bash
# 如果使用Docker
docker-compose down

# 如果直接运行
pkill -f "new-api" || true

# 检查端口占用
lsof -i :3000 || echo "端口3000未被占用"
```

### 步骤4：备份现有配置

```bash
# 备份数据库和配置文件
mkdir -p backup/$(date +%Y%m%d_%H%M%S)

# 如果使用SQLite
cp data/new-api.db backup/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || echo "无SQLite文件"

# 备份Docker配置
cp docker-compose.yml backup/$(date +%Y%m%d_%H%M%S)/

# 备份环境变量文件
cp .env backup/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || echo "无.env文件"
```

### 步骤5：部署新版本

#### Docker部署 (推荐)

```bash
# 重新构建镜像
docker-compose build --no-cache

# 启动服务
docker-compose up -d

# 查看启动日志
docker-compose logs -f new-api

# 验证服务状态
curl -s http://localhost:3000/api/status | jq . || echo "服务启动成功"
```

#### 直接运行部署

```bash
# 设置环境变量
export SESSION_SECRET="your-very-long-random-secret-key-here"
export SQL_DSN="root:password@tcp(mysql:3306)/new-api"

# 运行程序
./new-api &

# 查看进程
ps aux | grep new-api

# 查看日志
tail -f logs/new-api.log
```

### 步骤6：验证部署

```bash
# 1. 检查服务状态
curl -s http://localhost:3000/api/status

# 2. 检查Session Cookie配置
# 打开浏览器访问 http://newapi.mrpzx.cn
# 打开开发者工具 -> Application -> Cookies
# 确认Session Cookie的Domain为 .mrpzx.cn

# 3. 测试跨域功能
# 在 writting.mrpzx.cn 中测试API调用
curl -H "Origin: https://writting.mrpzx.cn" \
     -H "Cookie: session=your-session-value" \
     http://newapi.mrpzx.cn/api/user/self

# 4. 检查数据库迁移
# 确认所有表都存在
mysql -u root -p new-api -e "SHOW TABLES;"
```

### 步骤7：回滚方案

```bash
# 如果需要回滚
cd backup/$(ls -t backup/ | head -1)

# 恢复配置文件
cp docker-compose.yml ../
cp .env ../ 2>/dev/null || true

# 恢复数据库
cp new-api.db ../data/ 2>/dev/null || true

# 重新部署旧版本
cd ..
docker-compose down
docker-compose up -d
```

## 🔧 配置要求

### 环境变量设置

```bash
# 生产环境必需
SESSION_SECRET=your-very-long-random-secret-key-here
SQL_DSN=root:password@tcp(mysql:3306)/new-api

# 可选配置
DEBUG=false
MEMORY_CACHE_ENABLED=true
REDIS_CONN_STRING=redis://redis:6379

# 生产环境安全设置
SECURE_COOKIES=true
```

### Nginx反向代理配置 (推荐)

```nginx
# /etc/nginx/sites-available/new-api
server {
    listen 80;
    server_name newapi.mrpzx.cn;

    # 强制HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name newapi.mrpzx.cn;

    # SSL证书配置
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # 安全头
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # Session Cookie配置
    proxy_cookie_domain newapi.mrpzx.cn .mrpzx.cn;
    proxy_cookie_path / /;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket支持 (如果需要)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 防火墙配置

```bash
# 开放端口
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3000

# 或者使用firewalld
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

## 📊 监控和维护

### 系统监控

```bash
# CPU和内存使用
top -p $(pgrep new-api)

# 磁盘使用
df -h

# 网络连接
netstat -tlnp | grep :3000

# 错误日志
tail -f /var/log/new-api/error.log
```

### 应用监控

```bash
# 健康检查
curl -f http://localhost:3000/api/status

# API响应时间监控
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:3000/api/status

# 数据库连接检查
mysql -u root -p -e "SELECT 1;" new-api
```

### 日志轮转

```bash
# 配置logrotate
cat > /etc/logrotate.d/new-api << EOF
/var/log/new-api/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
    postrotate
        systemctl reload new-api
    endscript
}
EOF
```

## 🚨 故障排除

### 常见问题

1. **编译失败**
   ```bash
   # 检查Go版本
   go version

   # 清理模块缓存
   go clean -modcache
   go mod download

   # 重新编译
   go build -v .
   ```

2. **服务启动失败**
   ```bash
   # 检查端口占用
   lsof -i :3000

   # 检查日志
   docker-compose logs new-api

   # 检查配置文件
   cat docker-compose.yml
   ```

3. **数据库连接失败**
   ```bash
   # 测试数据库连接
   mysql -h localhost -u root -p new-api -e "SELECT 1;"

   # 检查环境变量
   echo $SQL_DSN
   ```

4. **Session不共享**
   ```bash
   # 检查Cookie设置
   curl -I http://newapi.mrpzx.cn/login

   # 确认Domain设置
   grep "Domain.*mrpzx" main.go
   ```

## 📞 技术支持

部署完成后，如果遇到问题：

1. **检查日志**: `docker-compose logs new-api`
2. **验证配置**: 确认环境变量和数据库连接
3. **测试功能**: 使用API文档中的示例测试
4. **检查网络**: 确认防火墙和反向代理配置

## ✅ 部署检查清单

- [ ] Go代码已成功编译
- [ ] 环境变量已正确设置
- [ ] 数据库连接正常
- [ ] Session Cookie Domain为 .mrpzx.cn
- [ ] HTTPS证书已配置
- [ ] Nginx反向代理已配置
- [ ] 防火墙规则已设置
- [ ] 服务已启动并响应
- [ ] 跨域功能已验证
- [ ] 监控和日志已配置

---

**部署完成时间**: 预计15-30分钟
**维护难度**: 中等
**建议频率**: 代码修改后立即部署
# Docker & Docker Compose 速查表

## 🚀 快速部署 (New API)

```bash
# 一键部署修改后的代码
./deploy.sh

# 验证部署是否成功
./verify_deployment.sh

# 查看服务状态
docker-compose ps

# 查看实时日志
docker-compose logs -f new-api
```

## 🐳 Docker 核心命令

### 容器操作
```bash
docker ps              # 查看运行容器
docker ps -a           # 查看所有容器
docker start <name>    # 启动容器
docker stop <name>     # 停止容器
docker restart <name>  # 重启容器
docker rm <name>       # 删除容器
docker exec -it <name> bash  # 进入容器
```

### 镜像操作
```bash
docker images          # 查看镜像
docker pull <image>    # 拉取镜像
docker build -t <name> .  # 构建镜像
docker rmi <image>     # 删除镜像
docker image prune     # 清理悬空镜像
```

### 日志监控
```bash
docker logs <name>     # 查看日志
docker logs -f <name>  # 实时日志
docker stats           # 资源监控
```

## 🐙 Docker Compose 核心命令

### 服务管理
```bash
docker-compose up              # 启动服务
docker-compose up -d           # 后台启动
docker-compose down            # 停止服务
docker-compose restart         # 重启服务
docker-compose ps              # 查看状态
```

### 构建部署
```bash
docker-compose build           # 构建镜像
docker-compose build --no-cache # 强制重建
docker-compose pull            # 拉取镜像
docker-compose config          # 验证配置
```

### 日志调试
```bash
docker-compose logs            # 查看日志
docker-compose logs -f         # 实时日志
docker-compose logs <service>  # 指定服务日志
docker-compose exec <service> bash  # 进入服务
```

## 🔧 New API 项目专用

### 数据库操作
```bash
# 进入MySQL
docker-compose exec mysql mysql -u root -p

# 备份数据库
docker-compose exec mysql mysqldump -u root -p new-api > backup.sql

# 恢复数据库
docker-compose exec mysql mysql -u root -p new-api < backup.sql
```

### Redis操作
```bash
# 进入Redis
docker-compose exec redis redis-cli

# 清空缓存
docker-compose exec redis redis-cli flushall
```

### 应用调试
```bash
# 查看应用日志
docker-compose logs -f new-api

# 检查应用状态
curl http://localhost:3000/api/status

# 进入应用容器
docker-compose exec new-api bash
```

## 🚨 故障排除

### 端口冲突
```bash
lsof -i :3000              # 检查端口占用
docker-compose port new-api 3000  # 查看端口映射
```

### 容器问题
```bash
docker-compose logs --tail=50 new-api  # 最近日志
docker-compose restart new-api         # 重启服务
docker-compose up --force-recreate new-api  # 重新创建
```

### 空间清理
```bash
docker system prune -a     # 清理所有未使用资源
docker volume prune        # 清理未使用卷
docker image prune -a      # 清理未使用镜像
```

## 📊 监控命令

```bash
docker stats                  # 实时资源监控
docker system df             # 磁盘使用情况
docker events                # 系统事件
docker inspect <container>   # 容器详细信息
```

## 🔄 备份恢复

```bash
# 备份数据库
docker-compose exec mysql mysqldump -u root -p new-api > backup.sql

# 恢复数据库
docker-compose exec mysql mysql -u root -p new-api < backup.sql

# 备份卷数据
docker run --rm -v <volume>:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .
```

## ⚡ 常用组合命令

```bash
# 完整重启
docker-compose down && docker-compose up -d

# 重建部署
docker-compose down && docker-compose build --no-cache && docker-compose up -d

# 查看完整状态
docker-compose ps && docker stats --no-stream

# 清理重启
docker system prune -f && docker-compose restart
```

## 🎯 New API 部署流程

1. **备份数据**
   ```bash
   mkdir backup/$(date +%Y%m%d_%H%M%S)
   cp docker-compose.yml backup/
   ```

2. **部署更新**
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

3. **验证部署**
   ```bash
   docker-compose ps
   curl http://localhost:3000/api/status
   docker-compose logs -f new-api
   ```

---

## 📞 快速帮助

| 问题 | 命令 |
|------|------|
| 服务启动失败 | `docker-compose logs new-api` |
| 端口被占用 | `lsof -i :3000` |
| 磁盘空间不足 | `docker system prune -a` |
| 数据库连接失败 | `docker-compose exec new-api ping mysql` |
| 容器无法启动 | `docker-compose up --force-recreate` |

---

## 🎉 记住的核心命令

**启动服务**: `docker-compose up -d`
**查看状态**: `docker-compose ps`
**查看日志**: `docker-compose logs -f`
**停止服务**: `docker-compose down`
**重启服务**: `docker-compose restart`

**New API专用**:
- 部署: `./deploy.sh`
- 验证: `./verify_deployment.sh`
- 调试: `docker-compose logs -f new-api`

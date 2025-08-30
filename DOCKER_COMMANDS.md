# Docker & Docker Compose 命令指南

## 🐳 Docker 基础命令

### 容器管理

```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 查看容器详情
docker inspect <container_name>

# 启动容器
docker start <container_name>

# 停止容器
docker stop <container_name>

# 重启容器
docker restart <container_name>

# 删除容器
docker rm <container_name>

# 强制删除运行中的容器
docker rm -f <container_name>

# 进入容器shell
docker exec -it <container_name> /bin/bash
```

### 镜像管理

```bash
# 查看本地镜像
docker images

# 拉取镜像
docker pull <image_name>:<tag>

# 构建镜像
docker build -t <image_name>:<tag> .

# 删除镜像
docker rmi <image_name>:<tag>

# 清理悬空镜像
docker image prune

# 清理所有未使用的镜像
docker image prune -a
```

### 日志和监控

```bash
# 查看容器日志
docker logs <container_name>

# 实时查看日志
docker logs -f <container_name>

# 查看最近的日志
docker logs --tail 100 <container_name>

# 查看容器资源使用
docker stats <container_name>

# 查看容器端口映射
docker port <container_name>
```

## 🐙 Docker Compose 命令

### 项目管理

```bash
# 启动服务
docker-compose up

# 后台启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs

# 实时查看日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs <service_name>
```

### 构建和配置

```bash
# 构建镜像
docker-compose build

# 强制重新构建
docker-compose build --no-cache

# 仅构建特定服务
docker-compose build <service_name>

# 验证配置文件
docker-compose config

# 拉取所有镜像
docker-compose pull
```

### 服务操作

```bash
# 启动特定服务
docker-compose up <service_name>

# 停止特定服务
docker-compose stop <service_name>

# 重启特定服务
docker-compose restart <service_name>

# 扩展服务实例
docker-compose up --scale <service_name>=3

# 执行服务中的命令
docker-compose exec <service_name> <command>
```

## 🚀 New API 项目专用命令

### 部署和更新

```bash
# 完整部署流程
cd /path/to/new-api

# 1. 停止现有服务
docker-compose down

# 2. 重新构建镜像（代码修改后）
docker-compose build --no-cache

# 3. 启动服务
docker-compose up -d

# 4. 查看启动状态
docker-compose ps

# 5. 查看启动日志
docker-compose logs -f new-api
```

### 数据库操作

```bash
# 进入MySQL容器
docker-compose exec mysql mysql -u root -p

# 备份数据库
docker-compose exec mysql mysqldump -u root -p new-api > backup.sql

# 恢复数据库
docker-compose exec mysql mysql -u root -p new-api < backup.sql
```

### Redis操作

```bash
# 进入Redis容器
docker-compose exec redis redis-cli

# 查看Redis信息
docker-compose exec redis redis-cli info

# 清空Redis缓存
docker-compose exec redis redis-cli flushall
```

### 日志管理

```bash
# 查看应用日志
docker-compose logs -f new-api

# 查看数据库日志
docker-compose logs -f mysql

# 查看Redis日志
docker-compose logs -f redis

# 查看所有服务日志
docker-compose logs -f
```

### 服务监控

```bash
# 查看服务资源使用
docker stats

# 查看容器端口
docker-compose port new-api 3000

# 检查服务健康状态
curl http://localhost:3000/api/status

# 查看容器详情
docker inspect new-api_new-api_1
```

## 🔧 故障排除命令

### 端口冲突检查

```bash
# 查看端口占用
lsof -i :3000
netstat -tlnp | grep :3000

# 杀死占用进程
sudo kill -9 <PID>
```

### 容器问题排查

```bash
# 查看容器错误日志
docker-compose logs --tail=50 new-api

# 检查容器文件系统
docker-compose exec new-api ls -la

# 检查环境变量
docker-compose exec new-api env

# 检查网络连接
docker-compose exec new-api ping mysql
docker-compose exec new-api ping redis
```

### 磁盘空间清理

```bash
# 查看磁盘使用
df -h

# Docker占用空间
docker system df

# 清理未使用的容器
docker container prune

# 清理未使用的镜像
docker image prune -a

# 清理未使用的网络
docker network prune

# 清理未使用的卷
docker volume prune

# 清理所有未使用的资源
docker system prune -a
```

## 📊 监控和维护

### 系统监控

```bash
# Docker系统信息
docker system info

# 磁盘使用详情
docker system df -v

# 实时监控
docker stats --all

# 事件监控
docker events
```

### 性能监控

```bash
# 容器性能详情
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# 查看容器进程
docker-compose top

# 查看容器资源限制
docker inspect <container_id> | grep -A 10 "Limits"
```

## 🔄 数据备份和恢复

### 卷管理

```bash
# 查看所有卷
docker volume ls

# 查看卷详情
docker volume inspect <volume_name>

# 创建卷
docker volume create <volume_name>

# 删除卷
docker volume rm <volume_name>

# 备份卷数据
docker run --rm -v <volume_name>:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .
```

### 数据库备份

```bash
# 备份MySQL数据
docker-compose exec mysql mysqldump -u root -p new-api > backup_$(date +%Y%m%d_%H%M%S).sql

# 备份Redis数据
docker-compose exec redis redis-cli save
docker cp $(docker-compose ps -q redis):/data/dump.rdb ./redis_backup.rdb
```

## 🌐 网络管理

### 网络命令

```bash
# 查看网络
docker network ls

# 查看网络详情
docker network inspect <network_name>

# 创建网络
docker network create <network_name>

# 连接容器到网络
docker network connect <network_name> <container_name>

# 断开容器网络连接
docker network disconnect <network_name> <container_name>
```

### 端口映射检查

```bash
# 查看端口映射
docker port <container_name>

# 查看容器网络配置
docker inspect <container_name> | grep -A 20 "NetworkSettings"

# 测试端口连通性
telnet localhost 3000
curl http://localhost:3000
```

## 🚨 紧急恢复

### 容器崩溃恢复

```bash
# 重启失败的容器
docker-compose restart <service_name>

# 重新创建容器
docker-compose up --force-recreate <service_name>

# 完全重建服务
docker-compose up --build --force-recreate <service_name>
```

### 数据恢复

```bash
# 从备份恢复数据库
docker-compose exec -T mysql mysql -u root -p new-api < backup.sql

# 恢复Redis数据
docker cp ./redis_backup.rdb $(docker-compose ps -q redis):/data/dump.rdb
docker-compose exec redis redis-cli shutdown
docker-compose restart redis
```

## 📝 常用组合命令

### 快速重启服务

```bash
docker-compose down && docker-compose up -d && docker-compose logs -f
```

### 完整清理重启

```bash
docker-compose down
docker system prune -f
docker-compose build --no-cache
docker-compose up -d
docker-compose logs -f
```

### 健康检查

```bash
# 检查所有服务状态
docker-compose ps

# 检查应用健康
curl -f http://localhost:3000/api/status

# 检查数据库连接
docker-compose exec new-api nc -z mysql 3306 && echo "MySQL OK" || echo "MySQL FAIL"

# 检查Redis连接
docker-compose exec new-api nc -z redis 6379 && echo "Redis OK" || echo "Redis FAIL"
```

## 🎯 New API 快速部署脚本

基于上述命令，我们创建了一键部署脚本：

```bash
# 一键部署
./deploy.sh

# 验证部署
./verify_deployment.sh

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f new-api
```

---

## 📚 命令速查表

| 操作 | Docker | Docker Compose |
|------|--------|----------------|
| 查看状态 | `docker ps` | `docker-compose ps` |
| 查看日志 | `docker logs` | `docker-compose logs` |
| 启动 | `docker start` | `docker-compose up` |
| 停止 | `docker stop` | `docker-compose down` |
| 重启 | `docker restart` | `docker-compose restart` |
| 构建 | `docker build` | `docker-compose build` |
| 删除 | `docker rm` | `docker-compose rm` |
| 执行命令 | `docker exec` | `docker-compose exec` |

**记住**: 在New API项目目录下运行所有`docker-compose`命令！ 📁

---

*此指南针对New API项目优化，包含项目特定的部署和维护命令。*

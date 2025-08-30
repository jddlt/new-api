#!/bin/bash

# New API 快速部署脚本
# 用于部署修改后的Go代码

set -e

echo "🚀 开始部署 New API..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查docker-compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose 未安装，请先安装 docker-compose"
    exit 1
fi

# 创建备份
echo "📦 创建备份..."
BACKUP_DIR="backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f "docker-compose.yml" ]; then
    cp docker-compose.yml "$BACKUP_DIR/"
    echo "✅ docker-compose.yml 已备份到 $BACKUP_DIR"
fi

if [ -f ".env" ]; then
    cp .env "$BACKUP_DIR/"
    echo "✅ .env 已备份到 $BACKUP_DIR"
fi

if [ -d "data" ]; then
    cp -r data "$BACKUP_DIR/"
    echo "✅ data 目录已备份到 $BACKUP_DIR"
fi

# 停止现有服务
echo "🛑 停止现有服务..."
docker-compose down || true

# 清理旧镜像（可选）
echo "🧹 清理旧镜像..."
docker image prune -f || true

# 重新构建镜像
echo "🔨 重新构建镜像..."
docker-compose build --no-cache

# 启动服务
echo "▶️ 启动服务..."
docker-compose up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 验证服务状态
echo "🔍 验证服务状态..."
if curl -f -s http://localhost:3000/api/status > /dev/null; then
    echo "✅ 服务启动成功！"

    # 获取服务信息
    STATUS=$(curl -s http://localhost:3000/api/status)
    echo "📊 服务状态: $STATUS"

    # 检查Session Cookie配置
    echo "🍪 检查Session Cookie配置..."
    RESPONSE=$(curl -I -s http://localhost:3000/api/status | grep -i "set-cookie" || echo "No Set-Cookie header")

    if echo "$RESPONSE" | grep -q "Domain=.mrpzx.cn"; then
        echo "✅ Session Cookie Domain 已正确设置为 .mrpzx.cn"
    else
        echo "⚠️  Session Cookie Domain 配置可能有问题"
        echo "请检查 main.go 中的 Session 配置"
    fi

else
    echo "❌ 服务启动失败！"

    # 显示错误日志
    echo "📋 错误日志:"
    docker-compose logs --tail=20 new-api

    # 显示容器状态
    echo "📦 容器状态:"
    docker-compose ps

    exit 1
fi

# 显示部署信息
echo ""
echo "🎉 部署完成！"
echo "📋 部署信息:"
echo "   - 服务地址: http://localhost:3000"
echo "   - API文档: /COMPREHENSIVE_API_DOCUMENTATION.md"
echo "   - 备份位置: $BACKUP_DIR"
echo ""
echo "🔧 常用命令:"
echo "   - 查看日志: docker-compose logs -f new-api"
echo "   - 重启服务: docker-compose restart"
echo "   - 停止服务: docker-compose down"
echo "   - 回滚: cp $BACKUP_DIR/* ./ && docker-compose up -d"

echo ""
echo "✅ 部署成功完成！请访问 http://localhost:3000 测试服务。"

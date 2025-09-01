#!/bin/bash

# 部署AMD64镜像到服务器

SERVER_HOST="117.72.188.131"
SERVER_USER="root"
SERVER_PATH="/root/new-api"
LOCAL_TAR="new-api-amd64.tar"

echo "🚀 部署AMD64镜像到服务器..."

# 检查文件
if [ ! -f "$LOCAL_TAR" ]; then
    echo "❌ 找不到AMD64镜像文件，请先运行: ./build-for-amd64.sh"
    exit 1
fi

echo "📦 上传AMD64镜像..."
scp "$LOCAL_TAR" "$SERVER_USER@$SERVER_HOST:/tmp/"

echo "🔄 在服务器上加载镜像..."
ssh "$SERVER_USER@$SERVER_HOST" "docker load < /tmp/$LOCAL_TAR"

echo "🛑 停止旧容器..."
ssh "$SERVER_USER@$SERVER_HOST" "cd $SERVER_PATH && docker compose stop new-api"

echo "🗑️ 删除旧容器..."
ssh "$SERVER_USER@$SERVER_HOST" "cd $SERVER_PATH && docker compose rm -f new-api"

echo "🚀 启动新容器..."
ssh "$SERVER_USER@$SERVER_HOST" "cd $SERVER_PATH && docker compose up -d new-api"

echo "⏳ 等待服务启动..."
sleep 10

echo "✅ 部署完成！"
echo ""
echo "📊 检查服务状态:"
ssh "$SERVER_USER@$SERVER_HOST" "cd $SERVER_PATH && docker compose ps"

echo ""
echo "🔍 检查应用日志:"
ssh "$SERVER_USER@$SERVER_HOST" "cd $SERVER_PATH && docker compose logs --tail=10 new-api"

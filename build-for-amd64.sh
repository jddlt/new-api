#!/bin/bash

# 为AMD64架构构建镜像

set -e

echo "🏗️ 为AMD64服务器构建镜像..."

# 检查Docker buildx
if ! docker buildx version &> /dev/null; then
    echo "❌ Docker buildx 不可用，请更新Docker"
    exit 1
fi

# echo "📦 构建前端..."
# cd web
# npm install --legacy-peer-deps
# DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat ../VERSION) npm run build
# cd ..

echo "🔧 构建后端..."
# 为AMD64架构构建Go二进制
GOOS=linux GOARCH=amd64 go build -ldflags "-s -w -X 'one-api/common.Version=$(cat VERSION)'" -o one-api-amd64

# 备份原文件
if [ -f "one-api" ]; then
    mv one-api one-api-arm64-backup
fi

# 使用AMD64版本
mv one-api-amd64 one-api

echo "🐳 构建AMD64 Docker镜像..."
# 使用普通docker build，因为网络问题
docker build -t new-api:latest -t new-api:amd64 .

echo "💾 保存镜像..."
docker save new-api:latest > new-api-amd64.tar

echo "✅ AMD64镜像构建完成！"
echo ""
echo "📋 文件信息:"
ls -lh new-api-amd64.tar
echo ""
echo "🚀 上传命令:"
echo "scp new-api-amd64.tar root@117.72.188.131:/tmp/"

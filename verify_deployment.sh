#!/bin/bash

# New API 部署验证脚本
# 验证修改后的服务是否正常工作

echo "🔍 开始验证 New API 部署..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 验证函数
check_service() {
    echo -n "检查服务状态... "
    if curl -f -s http://localhost:3000/api/status > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 正常${NC}"
        return 0
    else
        echo -e "${RED}❌ 失败${NC}"
        return 1
    fi
}

check_session_cookie() {
    echo -n "检查Session Cookie配置... "
    RESPONSE=$(curl -I -s http://localhost:3000/api/status 2>/dev/null | grep -i "set-cookie" | head -1 || echo "")

    if echo "$RESPONSE" | grep -q "Domain=.mrpzx.cn"; then
        echo -e "${GREEN}✅ 正确 (.mrpzx.cn)${NC}"
        return 0
    elif echo "$RESPONSE" | grep -q "set-cookie"; then
        echo -e "${YELLOW}⚠️ 存在但Domain不正确${NC}"
        echo "  当前Cookie: $RESPONSE"
        return 1
    else
        echo -e "${YELLOW}⚠️ 未设置Session Cookie${NC}"
        return 1
    fi
}

check_api_response() {
    local endpoint=$1
    local description=$2

    echo -n "检查 $description... "
    if curl -f -s "http://localhost:3000$endpoint" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 正常${NC}"
        return 0
    else
        echo -e "${RED}❌ 失败${NC}"
        return 1
    fi
}

check_cross_domain_headers() {
    echo -n "检查跨域头设置... "
    RESPONSE=$(curl -I -s -H "Origin: https://writting.mrpzx.cn" http://localhost:3000/api/status 2>/dev/null)

    if echo "$RESPONSE" | grep -q "Access-Control-Allow-Origin"; then
        echo -e "${GREEN}✅ 已配置${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️ 未配置跨域头${NC}"
        return 1
    fi
}

# 主验证流程
echo "========================================"
echo "      New API 部署验证"
echo "========================================"

FAILED_CHECKS=0

# 1. 检查服务状态
if ! check_service; then
    ((FAILED_CHECKS++))
    echo "❌ 服务未正常启动，请检查日志："
    echo "   docker-compose logs new-api"
fi

# 2. 检查Session Cookie配置
if ! check_session_cookie; then
    ((FAILED_CHECKS++))
    echo "❌ Session Cookie配置不正确，请检查 main.go 中的配置"
fi

# 3. 检查关键API端点
check_api_response "/api/status" "系统状态接口" || ((FAILED_CHECKS++))
check_api_response "/api/about" "系统信息接口" || ((FAILED_CHECKS++))
check_api_response "/api/models" "模型列表接口" || ((FAILED_CHECKS++))

# 4. 检查跨域配置
check_cross_domain_headers || ((FAILED_CHECKS++))

echo ""
echo "========================================"

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}🎉 所有验证通过！部署成功！${NC}"
    echo ""
    echo "📋 验证结果:"
    echo "   ✅ 服务正常运行"
    echo "   ✅ Session Cookie配置正确"
    echo "   ✅ API端点响应正常"
    echo "   ✅ 跨域配置正确"
    echo ""
    echo "🚀 现在可以开始使用跨域功能了！"
    echo "   - newapi.mrpzx.cn 已配置Session共享"
    echo "   - writting.mrpzx.cn 可以读取Session"
    echo "   - 无需额外的认证逻辑"

    # 显示使用示例
    echo ""
    echo "💡 使用示例:"
    echo "   1. 在 newapi.mrpzx.cn 登录"
    echo "   2. 访问 writting.mrpzx.cn"
    echo "   3. Session会自动共享，无需重新登录"
else
    echo -e "${RED}❌ 发现 $FAILED_CHECKS 个问题需要解决${NC}"
    echo ""
    echo "🔧 解决建议:"
    echo "   1. 检查服务日志: docker-compose logs new-api"
    echo "   2. 确认环境变量设置正确"
    echo "   3. 验证数据库连接正常"
    echo "   4. 检查防火墙和端口配置"
    echo ""
    echo "📞 如需帮助，请查看部署指南: DEPLOYMENT_GUIDE.md"
    exit 1
fi

echo ""
echo "========================================"

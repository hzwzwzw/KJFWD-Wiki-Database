#!/bin/bash

# KJFWD Wiki 部署脚本
# 用于快速部署 Wiki.js

set -e

echo "================================================"
echo "KJFWD Wiki.js 部署脚本"
echo "================================================"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ 错误：Docker 未安装"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! docker compose version &> /dev/null; then
    echo "❌ 错误：Docker Compose 未安装或版本过低"
    echo "请升级到 Docker Compose v2: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker 环境检查通过"
echo ""

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "📝 创建环境配置文件..."
    cp .env.example .env
    echo "⚠️  请编辑 .env 文件，修改数据库密码等配置"
    echo ""
    read -p "是否现在编辑 .env 文件？(y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} .env
    fi
else
    echo "✅ 环境配置文件已存在"
fi

echo ""
echo "🚀 启动 Wiki.js 服务..."
docker compose up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 5

# 检查服务状态
if docker compose ps | grep -q "running"; then
    echo "✅ 服务启动成功！"
    echo ""
    echo "================================================"
    echo "访问信息："
    echo "  本地地址: http://localhost:3000"
    echo ""
    echo "首次访问会进入管理员设置向导"
    echo "================================================"
    echo ""
    echo "常用命令："
    echo "  查看日志: docker compose logs -f wiki"
    echo "  停止服务: docker compose stop"
    echo "  重启服务: docker compose restart"
    echo "================================================"
else
    echo "❌ 服务启动失败，请查看日志："
    echo "  docker compose logs"
fi

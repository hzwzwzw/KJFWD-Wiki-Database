#!/bin/bash

# KJFWD Wiki 恢复脚本
# 用于从备份恢复数据库和数据卷

set -e

BACKUP_DIR="./backups"

echo "================================================"
echo "KJFWD Wiki 恢复脚本"
echo "================================================"
echo ""

# 检查备份目录
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ 备份目录不存在: $BACKUP_DIR"
    exit 1
fi

# 列出可用的备份
echo "📋 可用的数据库备份："
ls -lh "$BACKUP_DIR"/database_*.sql 2>/dev/null || echo "  (无)"
echo ""

# 选择要恢复的备份
read -p "请输入要恢复的数据库备份文件名（不含路径）: " DB_BACKUP
DB_BACKUP_PATH="$BACKUP_DIR/$DB_BACKUP"

if [ ! -f "$DB_BACKUP_PATH" ]; then
    echo "❌ 备份文件不存在: $DB_BACKUP_PATH"
    exit 1
fi

# 确认操作
echo ""
echo "⚠️  警告：此操作将覆盖现有数据！"
echo "即将恢复: $DB_BACKUP_PATH"
echo ""
read -p "确认继续？(yes/NO) " -r
if [ "$REPLY" != "yes" ]; then
    echo "❌ 操作已取消"
    exit 0
fi

# 停止服务
echo ""
echo "🛑 停止 Wiki.js 服务..."
docker compose stop wiki

# 恢复数据库
echo ""
echo "📥 恢复数据库..."
cat "$DB_BACKUP_PATH" | docker compose exec -T db psql -U wikijs wiki
echo "✅ 数据库恢复完成"

# 重启服务
echo ""
echo "🚀 重启服务..."
docker compose start wiki

echo ""
echo "================================================"
echo "✅ 恢复完成！"
echo ""
echo "请访问 http://localhost:3000 验证"
echo "================================================"

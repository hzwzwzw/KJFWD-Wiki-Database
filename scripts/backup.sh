#!/bin/bash

# KJFWD Wiki 备份脚本
# 用于备份数据库和数据卷

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "================================================"
echo "KJFWD Wiki 备份脚本"
echo "================================================"
echo ""

# 创建备份目录
mkdir -p "$BACKUP_DIR"

echo "📦 开始备份..."
echo ""

# 备份数据库
echo "1/3 备份 PostgreSQL 数据库..."
docker compose exec -T db pg_dump -U wikijs wiki > "$BACKUP_DIR/database_$TIMESTAMP.sql"
echo "✅ 数据库备份完成: $BACKUP_DIR/database_$TIMESTAMP.sql"

# 备份 Wiki.js 数据卷
echo ""
echo "2/3 备份 Wiki.js 数据卷..."
docker run --rm \
    -v kjfwd-wiki-database_wiki-data:/data \
    -v "$(pwd)/$BACKUP_DIR":/backup \
    alpine tar czf "/backup/wiki-data_$TIMESTAMP.tar.gz" -C /data .
echo "✅ Wiki.js 数据卷备份完成: $BACKUP_DIR/wiki-data_$TIMESTAMP.tar.gz"

# 备份数据库数据卷
echo ""
echo "3/3 备份数据库数据卷..."
docker run --rm \
    -v kjfwd-wiki-database_db-data:/data \
    -v "$(pwd)/$BACKUP_DIR":/backup \
    alpine tar czf "/backup/db-data_$TIMESTAMP.tar.gz" -C /data .
echo "✅ 数据库数据卷备份完成: $BACKUP_DIR/db-data_$TIMESTAMP.tar.gz"

echo ""
echo "================================================"
echo "✅ 备份完成！"
echo ""
echo "备份文件位置："
echo "  - 数据库: $BACKUP_DIR/database_$TIMESTAMP.sql"
echo "  - Wiki 数据: $BACKUP_DIR/wiki-data_$TIMESTAMP.tar.gz"
echo "  - DB 数据: $BACKUP_DIR/db-data_$TIMESTAMP.tar.gz"
echo "================================================"

# 清理旧备份（保留最近 7 天）
echo ""
read -p "是否清理 7 天前的旧备份？(y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 清理旧备份..."
    find "$BACKUP_DIR" -name "database_*.sql" -mtime +7 -delete
    find "$BACKUP_DIR" -name "wiki-data_*.tar.gz" -mtime +7 -delete
    find "$BACKUP_DIR" -name "db-data_*.tar.gz" -mtime +7 -delete
    echo "✅ 清理完成"
fi

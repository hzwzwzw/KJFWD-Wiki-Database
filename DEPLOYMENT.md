# Wiki.js 部署指南

本文档说明如何使用 Docker Compose 部署 KJFWD Wiki 数据库。

## 系统要求

- Docker Engine 20.10+
- Docker Compose v2.0+
- 至少 2GB 可用内存
- 至少 10GB 可用磁盘空间

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/errorfg/KJFWD-Wiki-Database.git
cd KJFWD-Wiki-Database
```

### 2. 配置环境变量（可选）

如果需要自定义配置，复制环境变量模板并修改：

```bash
cp .env.example .env
# 编辑 .env 文件，修改数据库密码等配置
nano .env
```

### 3. 启动服务

```bash
# 启动服务
docker compose up -d

# 查看日志
docker compose logs -f wiki

# 查看运行状态
docker compose ps
```

### 4. 访问 Wiki.js

打开浏览器访问：`http://localhost:3000`

首次访问会进入管理员设置向导，按照提示完成配置。

### 5. 初始化 Wiki 内容

有两种方式导入现有的 Wiki 内容：

#### 方法 1：通过 Git 同步（推荐）

1. 在 Wiki.js 管理界面，进入 **Storage**
2. 添加 **Git** 作为存储后端
3. 配置仓库地址和认证信息
4. 选择同步模式和路径
5. 执行同步

#### 方法 2：手动导入

1. 在 Wiki.js 中手动创建页面
2. 将 markdown 文件内容复制到页面中

## 服务管理

### 停止服务

```bash
docker compose stop
```

### 重启服务

```bash
docker compose restart
```

### 停止并删除容器

```bash
docker compose down
```

### 停止并删除容器和数据卷（危险操作）

```bash
docker compose down -v
```

### 查看日志

```bash
# 查看所有服务日志
docker compose logs

# 查看 Wiki.js 日志
docker compose logs wiki

# 实时跟踪日志
docker compose logs -f wiki
```

## 数据备份

### 备份数据库

```bash
# 导出数据库
docker compose exec db pg_dump -U wikijs wiki > backup_$(date +%Y%m%d_%H%M%S).sql

# 或使用 pg_dumpall 备份所有数据库
docker compose exec db pg_dumpall -U wikijs > backup_all_$(date +%Y%m%d_%H%M%S).sql
```

### 备份数据卷

```bash
# 备份 Wiki.js 数据卷
docker run --rm -v kjfwd-wiki-database_wiki-data:/data -v $(pwd):/backup alpine tar czf /backup/wiki-data-backup.tar.gz -C /data .

# 备份数据库数据卷
docker run --rm -v kjfwd-wiki-database_db-data:/data -v $(pwd):/backup alpine tar czf /backup/db-data-backup.tar.gz -C /data .
```

### 恢复数据库

```bash
# 从备份文件恢复
cat backup_20231111_120000.sql | docker compose exec -T db psql -U wikijs wiki
```

### 恢复数据卷

```bash
# 恢复 Wiki.js 数据卷
docker run --rm -v kjfwd-wiki-database_wiki-data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/wiki-data-backup.tar.gz"

# 恢复数据库数据卷
docker run --rm -v kjfwd-wiki-database_db-data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/db-data-backup.tar.gz"
```

## 使用 Cloudflare Tunnel 配置域名访问

Wiki.js 目前仅在 localhost:3000 监听。为了通过域名访问，推荐使用 Cloudflare Tunnel。

### 1. 安装 cloudflared

**Linux/macOS:**

```bash
# 下载最新版本
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64
sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
```

**或使用包管理器：**

```bash
# Debian/Ubuntu
wget -q https://pkg.cloudflare.com/cloudflare-main.gpg -O- | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared focal main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt-get update && sudo apt-get install cloudflared
```

### 2. 登录 Cloudflare

```bash
cloudflared tunnel login
```

这会打开浏览器，选择你要使用的域名。

### 3. 创建 Tunnel

```bash
# 创建名为 kjfwd-wiki 的 tunnel
cloudflared tunnel create kjfwd-wiki

# 记录输出的 Tunnel ID
```

### 4. 配置 Tunnel

创建配置文件 `~/.cloudflared/config.yml`：

```yaml
tunnel: <你的 Tunnel ID>
credentials-file: /home/user/.cloudflared/<Tunnel ID>.json

ingress:
  - hostname: wiki.yourdomain.com
    service: http://localhost:3000
  - service: http_status:404
```

### 5. 配置 DNS

```bash
# 将域名指向 tunnel
cloudflared tunnel route dns kjfwd-wiki wiki.yourdomain.com
```

### 6. 启动 Tunnel

```bash
# 前台运行（测试）
cloudflared tunnel run kjfwd-wiki

# 后台运行（使用 systemd）
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

### 7. 验证

访问 `https://wiki.yourdomain.com`，应该能看到 Wiki.js 界面。

Cloudflare 会自动提供 SSL/TLS 证书。

## 更新 Wiki.js

```bash
# 拉取最新镜像
docker compose pull

# 重新创建容器
docker compose up -d
```

## 故障排除

### Wiki.js 无法启动

```bash
# 查看详细日志
docker compose logs wiki

# 检查数据库连接
docker compose exec wiki nc -zv db 5432
```

### 数据库连接失败

```bash
# 检查数据库状态
docker compose ps db

# 进入数据库容器
docker compose exec db psql -U wikijs wiki

# 查看数据库日志
docker compose logs db
```

### 端口已被占用

如果 3000 端口已被占用，修改 `docker-compose.yml`：

```yaml
ports:
  - "127.0.0.1:3001:3000"  # 改为其他端口
```

### 重置管理员密码

```bash
# 进入 Wiki.js 容器
docker compose exec wiki sh

# 使用 Wiki.js CLI 重置密码
node wiki configure
```

## 性能优化

### 增加 PostgreSQL 内存限制

编辑 `docker-compose.yml`，在 db 服务中添加：

```yaml
db:
  # ...
  command: postgres -c shared_buffers=256MB -c max_connections=200
```

### 启用 Redis 缓存（可选）

添加 Redis 服务到 `docker-compose.yml`：

```yaml
redis:
  image: redis:7-alpine
  container_name: kjfwd-wiki-redis
  restart: unless-stopped
  networks:
    - wiki-network
  volumes:
    - redis-data:/data

volumes:
  # ...
  redis-data:
```

然后在 Wiki.js 管理界面配置 Redis 缓存。

## 安全建议

1. **修改默认密码**：在 `.env` 或 `docker-compose.yml` 中修改数据库密码
2. **限制访问**：端口绑定到 `127.0.0.1`，避免直接暴露到公网
3. **使用 Cloudflare Tunnel**：提供自动 SSL/TLS 和 DDoS 防护
4. **定期备份**：设置自动备份脚本
5. **更新镜像**：定期更新 Docker 镜像到最新版本
6. **防火墙规则**：确保服务器防火墙配置正确

## 生产环境建议

1. 使用强密码
2. 启用 HTTPS（通过 Cloudflare Tunnel 或反向代理）
3. 配置自动备份
4. 监控资源使用
5. 设置日志轮转
6. 配置健康检查

## 相关链接

- [Wiki.js 官方文档](https://docs.requarks.io/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Cloudflare Tunnel 文档](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [PostgreSQL 文档](https://www.postgresql.org/docs/)

## 支持

如有问题，请提交 Issue 到项目仓库。

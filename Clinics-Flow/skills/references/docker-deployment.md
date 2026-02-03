# Docker Deployment for Odoo

## Production Docker Compose

```yaml
version: '3.8'

services:
  odoo:
    image: odoo:17.0
    container_name: odoo-prod
    restart: unless-stopped
    depends_on:
      - db
    ports:
      - "8069:8069"
    environment:
      - HOST=db
      - USER=odoo
      - PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=postgres
      - PGUSER=odoo
      - PGPASSWORD=${DB_PASSWORD}
    volumes:
      - odoo-web-data:/var/lib/odoo
      - ./config:/etc/odoo
      - ./custom_addons:/mnt/extra-addons
    networks:
      - odoo-network

  db:
    image: postgres:15
    container_name: odoo-db
    restart: unless-stopped
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_USER=odoo
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - odoo-db-data:/var/lib/postgresql/data/pgdata
    networks:
      - odoo-network

  nginx:
    image: nginx:alpine
    container_name: odoo-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - odoo-web-data:/var/lib/odoo:ro
    depends_on:
      - odoo
    networks:
      - odoo-network

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: odoo-pgadmin
    restart: unless-stopped
    environment:
      - PGADMIN_DEFAULT_EMAIL=${PGADMIN_EMAIL:-admin@example.com}
      - PGADMIN_DEFAULT_PASSWORD=${PGADMIN_PASSWORD:-admin}
    ports:
      - "5050:80"
    depends_on:
      - db
    networks:
      - odoo-network

volumes:
  odoo-web-data:
  odoo-db-data:

networks:
  odoo-network:
    driver: bridge
```

## Nginx Configuration

```nginx
upstream odoo {
    server odoo:8069;
}

upstream odoochat {
    server odoo:8072;
}

server {
    listen 80;
    server_name your-domain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL certificates
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Proxy timeouts
    proxy_connect_timeout 600s;
    proxy_send_timeout 600s;
    proxy_read_timeout 600s;
    send_timeout 600s;

    # Gzip compression
    gzip on;
    gzip_types text/css text/scss text/plain text/xml application/xml application/json application/javascript;

    # Static files
    location ~ ^/[^/]+/static/ {
        proxy_cache_valid 200 90m;
        proxy_buffering on;
        expires 864000;
        proxy_pass http://odoo;
    }

    # Long polling
    location /longpolling {
        proxy_pass http://odoochat;
    }

    # Main application
    location / {
        proxy_pass http://odoo;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Environment File (.env)

```bash
# Database
DB_PASSWORD=your-secure-password-here

# PGAdmin
PGADMIN_EMAIL=admin@yourdomain.com
PGADMIN_PASSWORD=your-admin-password

# Odoo
ODOO_ADMIN_PASSWD=your-admin-password
ODOO_DB_FILTER=^%d$

# Optional: SMTP
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

## Deployment Commands

### First Time Setup
```bash
# 1. Create directories
mkdir -p odoo-docker/{config,custom_addons,nginx/ssl}
cd odoo-docker

# 2. Create config file
cat > config/odoo.conf << 'EOF'
[options]
addons_path = /mnt/extra-addons
data_dir = /var/lib/odoo
admin_passwd = your-admin-password
db_host = db
db_port = 5432
db_user = odoo
db_password = your-db-password
proxy_mode = True
workers = 4
max_cron_threads = 2
EOF

# 3. Start services
docker-compose up -d

# 4. Check logs
docker-compose logs -f odoo

# 5. Access Odoo at http://localhost:8069
```

### Backup & Restore

#### Backup
```bash
# Database backup
docker-compose exec -T db pg_dump -U odoo -Fc odoo > backup_$(date +%Y%m%d).dump

# Filestore backup
tar -czf filestore_$(date +%Y%m%d).tar.gz /var/lib/docker/volumes/odoo_odoo-web-data/_data/
```

#### Restore
```bash
# Restore database
docker-compose exec -T db pg_restore -U odoo -d odoo < backup_20240101.dump

# Restore filestore
tar -xzf filestore_20240101.tar.gz -C /var/lib/docker/volumes/odoo_odoo-web-data/_data/
```

### Updates
```bash
# Update Odoo image
docker-compose pull odoo
docker-compose up -d odoo

# Update custom module
docker-compose exec odoo odoo -u my_module -d my_database --stop-after-init

# Restart
docker-compose restart odoo
```

### Maintenance
```bash
# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Restart all
docker-compose restart

# Stop all
docker-compose down

# Stop and remove volumes (CAREFUL!)
docker-compose down -v
```

## Development Setup

```yaml
version: '3.8'

services:
  odoo-dev:
    image: odoo:17.0
    container_name: odoo-dev
    depends_on:
      - db-dev
    ports:
      - "8069:8069"
      - "8072:8072"  # Live reload
    environment:
      - HOST=db-dev
      - USER=odoo
      - PASSWORD=odoo
      - DEV_MODE=1
    volumes:
      - ./custom_addons:/mnt/extra-addons
      - ./config:/etc/odoo
    command: odoo --dev=reload  # Auto-reload on code changes

  db-dev:
    image: postgres:15
    container_name: odoo-db-dev
    environment:
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=odoo
      - POSTGRES_DB=postgres
    ports:
      - "5432:5432"  # Expose for external tools
    volumes:
      - odoo-db-dev:/var/lib/postgresql/data

volumes:
  odoo-db-dev:
```

## Troubleshooting

### Database Connection Issues
```bash
# Check database is running
docker-compose exec db pg_isready -U odoo

# Reset database (WARNING: destroys data!)
docker-compose down -v
docker-compose up -d
```

### Permission Issues
```bash
# Fix file permissions
docker-compose exec odoo chown -R odoo:odoo /mnt/extra-addons
```

### Memory Issues
```yaml
# Add to odoo service
services:
  odoo:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

### Clean Slate
```bash
# Remove everything and start fresh
docker-compose down -v
docker system prune -a  # Removes all unused images
rm -rf odoo-web-data/*
docker-compose up -d
```

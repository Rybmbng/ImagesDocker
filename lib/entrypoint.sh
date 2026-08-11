#!/bin/bash
set -e

if [ -n "$SSH_ROOT_PASSWORD" ]; then
    echo "root:$SSH_ROOT_PASSWORD" | chpasswd
    echo "SSH root password configured"
fi

if [ "$APP_ENV" = "production" ]; then
    if [ -f /var/www/html/artisan ]; then
        echo "Running production optimizations..."
        php artisan config:cache || true
        php artisan route:cache || true
        php artisan view:cache || true
    fi
fi

if [ -d /var/www/html/storage ]; then
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true
    chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true
fi

echo "========================================"
echo "Container started successfully!"
echo "SSH: 22, Web: 80, Cron: active"
echo "========================================"

exec "$@"

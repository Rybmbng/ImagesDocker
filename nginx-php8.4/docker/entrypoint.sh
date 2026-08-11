#!/bin/bash
set -e

if [ -n "$SSH_ROOT_PASSWORD" ]; then
    echo "root:$SSH_ROOT_PASSWORD" | chpasswd
    echo "✓ SSH root password configured"
fi

if [ "$APP_ENV" = "production" ]; then
    echo "Running production optimizations..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    echo "✓ Laravel caches created"
fi

chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

echo "========================================"
echo "Nginx PHP 8.4 NodeJS 22"
echo "Container started successfully!"
echo "========================================"
echo "Services:"
echo "  - Nginx: http://localhost"
echo "  - SSH: Port 22"
echo "  - PHP-FPM: Running"
echo "  - Cron: Active (Laravel Scheduler)"
echo "========================================"

# Execute the main command
exec "$@"

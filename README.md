# Docker Image Builder

Multi-variant PHP/NodeJS Docker images. Built dan di-push ke Docker Hub via `build.sh`.

## Image Matrix

| #   | Folder                          | Type                | Base                              | Image Tag Pattern                       |
| --- | ------------------------------- | ------------------- | --------------------------------- | --------------------------------------- |
| 1   | `images/1-php7-apache`          | PHP 7.4 + Apache    | `php:7.4-apache` (Debian)         | `itbalitimbungan/php74-apache`          |
| 2   | `images/2-php7-nginx`           | PHP 7.4 + Nginx     | `php:7.4-fpm-alpine`              | `itbalitimbungan/php74-nginx`           |
| 3   | `images/3-php8-apache`          | PHP 8.x + Apache    | `php:${VER}-apache` (Debian)      | `itbalitimbungan/php8X-apache`          |
| 4   | `images/4-php8-nginx`           | PHP 8.x + Nginx     | `php:${VER}-fpm-alpine`           | `itbalitimbungan/php8X-nginx`           |
| 5   | `images/5-php8-apache-node`     | PHP 8.x + A + Node  | `php:${VER}-apache` (Debian)      | `itbalitimbungan/php8X-apache-nodeY`    |
| 6   | `images/6-php8-nginx-node`      | PHP 8.x + N + Node  | `php:${VER}-fpm-alpine`           | `itbalitimbungan/php8X-nginx-nodeY`     |
| 7   | `images/7-nodejs-only`          | NodeJS only         | `node:${VER}-alpine`              | `itbalitimbungan/nodejsY`               |

PHP versions supported: 7.4 (only — 7.0-7.3 archived dari Docker Hub), 8.0, 8.1, 8.2, 8.3, 8.4
NodeJS versions supported: 18, 20, 22

## Setiap Image Punya

- ✅ PHP runtime (FPM untuk nginx variant, mod_php untuk apache)
- ✅ Web server (Apache 2 atau Nginx)
- ✅ Supervisor (manage multi-process)
- ✅ Cron (Laravel scheduler-ready)
- ✅ SSH server (root login, password via `SSH_ROOT_PASSWORD` env)
- ✅ Git, Vim, Unzip, Curl
- ✅ Composer
- ✅ PHP extensions: bcmath, gd, intl, mbstring, mysqli, pdo_mysql, opcache, zip, redis
- ✅ PHP tuned: memory_limit 512M, upload 100M, opcache enabled
- ✅ Healthcheck (HTTP 200 pada port 80)

## Build & Push

```bash
# Build satu image
./build.sh --type php8-nginx --php 8.4

# Build + push
./build.sh --type php8-nginx --php 8.4 --push

# Build semua PHP 8.x + NodeJS 22 combination
./build.sh --type php8-nginx-node --all-php --node 22 --push

# Build SEMUA (seharian)
./build.sh --type all --all-php --all-node --push

# Login dulu
./build.sh --type php8-apache --php 8.4 --login --push
```

## Pakai Image yang Sudah Ada

```bash
# Pull
docker pull itbalitimbungan/php84-nginx:latest

# Run via docker-compose di folder image
cd images/4-php8-nginx
SSH_ROOT_PASSWORD=mysecret docker compose up -d

# Run langsung
docker run -d -p 80:80 -p 22:22 \
  -e SSH_ROOT_PASSWORD=mysecret \
  itbalitimbungan/php84-nginx:latest
```

## Struktur

```
docker builder/
├── build.sh                       # master build script
├── README.md
├── lib/                           # shared files
│   ├── apache/000-default.conf
│   ├── nginx/default.conf
│   ├── supervisor/supervisord.conf
│   ├── cron/sample
│   └── entrypoint.sh
└── images/
    ├── 1-php7-apache/
    ├── 2-php7-nginx/
    ├── 3-php8-apache/
    ├── 4-php8-nginx/
    ├── 5-php8-apache-node/
    ├── 6-php8-nginx-node/
    └── 7-nodejs-only/
```

## Versi PHP yang Tidak Tersedia

PHP 7.0, 7.1, 7.2, 7.3 sudah di-archive dari Docker Hub (`library/php`). Image #1 dan #2 hanya menyediakan PHP 7.4 (representatif).

## Catatan

- Base image **php:${VER}-apache** berbasis Debian (sesuai official PHP image — Alpine untuk apache tag tidak stabil).
- Base image **php:${VER}-fpm-alpine** berbasis Alpine (resmi, ringan).
- Semua image expose port 80 (web) dan 22 (SSH).
- Persistent storage: mount ke `/var/www/html`.
# ImagesDocker

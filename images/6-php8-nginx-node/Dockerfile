ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm-alpine

LABEL maintainer="ITBalitimbungan"
LABEL description="PHP 8.x FPM + Nginx + NodeJS (Alpine)"

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1

ARG NODE_VERSION=22

RUN apk add --no-cache \
        ca-certificates \
        curl \
        bash \
        nginx \
        supervisor \
        dcron \
        openssh-server \
        git \
        unzip \
        vim \
        tzdata \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        libzip-dev \
        icu-dev \
        oniguruma-dev \
        nodejs \
        npm \
        yarn \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        gd \
        intl \
        mbstring \
        mysqli \
        pdo_mysql \
        opcache \
        zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /tmp/* /var/cache/apk/*

RUN { \
        echo 'memory_limit = 512M'; \
        echo 'upload_max_filesize = 100M'; \
        echo 'post_max_size = 100M'; \
        echo 'max_execution_time = 300'; \
        echo 'cgi.fix_pathinfo = 0'; \
    } > /usr/local/etc/php/conf.d/zz-custom.ini

RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.memory_consumption=256'; \
        echo 'opcache.interned_strings_buffer=16'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache.ini

COPY lib/nginx/default.conf /etc/nginx/http.d/default.conf

RUN mkdir -p /var/run/sshd /var/log/supervisor /run/nginx \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config \
    && ssh-keygen -A

COPY lib/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY lib/cron/sample /etc/crontabs/root
RUN chmod 0600 /etc/crontabs/root && touch /var/log/cron.log

COPY lib/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80 22

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["/usr/local/bin/entrypoint.sh", "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

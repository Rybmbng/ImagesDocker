ARG PHP_VERSION=8.4
ARG NODE_VERSION=22
FROM php:${PHP_VERSION}-apache

LABEL maintainer="ITBalitimbungan"
LABEL description="PHP 8.x + Apache + NodeJS"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Jakarta \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1 \
    NODE_VERSION=${NODE_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        supervisor \
        cron \
        openssh-server \
        git \
        unzip \
        vim \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libzip-dev \
        libicu-dev \
        libonig-dev \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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

COPY lib/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite headers

RUN mkdir -p /var/run/sshd /var/log/supervisor \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config

COPY lib/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY lib/cron/sample /etc/cron.d/sample
RUN chmod 0644 /etc/cron.d/sample && crontab /etc/cron.d/sample && touch /var/log/cron.log

COPY lib/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80 22

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["/usr/local/bin/entrypoint.sh", "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

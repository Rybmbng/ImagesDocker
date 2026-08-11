FROM ubuntu:22.04

LABEL maintainer="ITBalitimbungan"
LABEL description="Nginx - PHP 8.4 NodeJS22"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Jakarta \
    PHP_VERSION=8.4 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1

RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    ca-certificates \
    gnupg \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update && apt-get install -y \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-opcache \
    nginx \
    supervisor \
    cron \
    openssh-server \
    git \
    unzip \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/${PHP_VERSION}/fpm/php.ini \
    && sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/g' /etc/php/${PHP_VERSION}/fpm/php.ini \
    && sed -i 's/post_max_size = .*/post_max_size = 100M/g' /etc/php/${PHP_VERSION}/fpm/php.ini \
    && sed -i 's/memory_limit = .*/memory_limit = 512M/g' /etc/php/${PHP_VERSION}/fpm/php.ini \
    && sed -i 's/max_execution_time = .*/max_execution_time = 300/g' /etc/php/${PHP_VERSION}/fpm/php.ini

RUN echo "opcache.enable=1" >> /etc/php/${PHP_VERSION}/fpm/conf.d/10-opcache.ini \
    && echo "opcache.memory_consumption=256" >> /etc/php/${PHP_VERSION}/fpm/conf.d/10-opcache.ini \
    && echo "opcache.interned_strings_buffer=16" >> /etc/php/${PHP_VERSION}/fpm/conf.d/10-opcache.ini \
    && echo "opcache.max_accelerated_files=10000" >> /etc/php/${PHP_VERSION}/fpm/conf.d/10-opcache.ini \
    && echo "opcache.revalidate_freq=60" >> /etc/php/${PHP_VERSION}/fpm/conf.d/10-opcache.ini \
    && echo "opcache.fast_shutdown=1" >> /etc/php/${PHP_VERSION}/fpm/conf.d/10-opcache.ini

RUN rm -f /etc/nginx/sites-enabled/default
COPY docker/nginx/default.conf /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

RUN mkdir -p /var/run/sshd /run/php \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config \
    && echo "X11Forwarding no" >> /etc/ssh/sshd_config

COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor

COPY docker/cron/sample /etc/cron.d/sample
RUN chmod 0644 /etc/cron.d/sample \
    && crontab /etc/cron.d/sample \
    && touch /var/log/cron.log

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash

RUN source ~/.bashrc 
RUN nvm install 22
RUN nvm use 22


WORKDIR /var/www/html

COPY --chown=www-data:www-data . /var/www/html

RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist \
    && composer dump-autoload --optimize --no-scripts --no-dev

RUN chown -R www-data:www-data /var/www/html 

EXPOSE 80 22

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

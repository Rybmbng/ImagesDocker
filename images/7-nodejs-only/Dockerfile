ARG NODE_VERSION=22
FROM node:${NODE_VERSION}-alpine

LABEL maintainer="ITBalitimbungan"
LABEL description="NodeJS only (Alpine) with SSH + cron + supervisor"

ENV NPM_CONFIG_LOGLEVEL=warn \
    NODE_ENV=production

RUN apk add --no-cache \
        ca-certificates \
        curl \
        bash \
        supervisor \
        dcron \
        openssh-server \
        git \
        unzip \
        vim \
        tzdata \
        python3 \
        py3-pip \
        alpine-sdk \
    && npm install -g npm@latest pnpm \
    && npm install -g yarn --force \
    && mkdir -p /var/run/sshd /var/log/supervisor \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config \
    && ssh-keygen -A \
    && rm -rf /tmp/* /var/cache/apk/*

COPY lib/cron/sample /etc/crontabs/root
RUN chmod 0600 /etc/crontabs/root && touch /var/log/cron.log

COPY lib/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY lib/supervisor/supervisord-node.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /var/www/html

EXPOSE 22 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD node -e "process.exit(0)" || exit 1

CMD ["/usr/local/bin/entrypoint.sh", "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

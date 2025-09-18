FROM php:8.4-apache

ARG ADMINER_VER

ENV ADMINER_VER="${ADMINER_VER}" \
    \
    PHP_MAX_EXECUTION_TIME=0 \
    PHP_POST_MAX_SIZE="512M" \
    PHP_UPLOAD_MAX_FILESIZE="512M" \
    PHP_CLI_MEMORY_LIMIT="512M"

RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
      postgresql-client \
      postgresql-server-dev-all; \
    docker-php-ext-install mysqli pgsql pdo_mysql pdo_pgsql; \
    base_url="https://github.com/vrana/adminer"; \
    curl -sSL "${base_url}/releases/download/v${ADMINER_VER}/adminer-${ADMINER_VER}.php" -o adminer.php; \
    curl -sSL "${base_url}/archive/v${ADMINER_VER}.tar.gz" -o source.tar.gz; \
    curl -sSL "https://github.com/TimWolla/docker-adminer/raw/master/5/plugin-loader.php" -o plugin-loader.php; \
    tar xzf source.tar.gz --strip-components=1 "adminer-${ADMINER_VER}/designs/" "adminer-${ADMINER_VER}/plugins/"; \
    mkdir -p /var/www/html/plugins-enabled; \
    apt-get purge -y --auto-remove \
      postgresql-server-dev-all; \
    rm -rf \
      /var/lib/apt/lists/* \
      source.tar.gz

COPY --chown=wodby:wodby index.php /var/www/html

COPY entrypoint.sh /

EXPOSE 80

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "apache2-foreground" ]

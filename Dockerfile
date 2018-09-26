ARG BASE_IMAGE_TAG

FROM wodby/php:${BASE_IMAGE_TAG}

ARG ADMINER_VER

ENV ADMINER_VER="${ADMINER_VER}" \
    \
    PHP_MAX_EXECUTION_TIME=0 \
    PHP_POST_MAX_SIZE="512M" \
    PHP_UPLOAD_MAX_FILESIZE="512M"

RUN set -ex; \
    base_url="https://github.com/vrana/adminer"; \
    curl -sSL "${base_url}/releases/download/v${ADMINER_VER}/adminer-${ADMINER_VER}.php" -o adminer.php; \
    curl -sSL "${base_url}/archive/v${ADMINER_VER}.tar.gz" -o source.tar.gz; \
    curl -sSL "https://github.com/TimWolla/docker-adminer/raw/master/4/plugin-loader.php" -o plugin-loader.php; \
    curl -sSL "https://raw.githubusercontent.com/TimWolla/docker-adminer/f31551fa8c81fca673b1233ca3f4889119e5e551/4/entrypoint.sh"; \
    tar xzf source.tar.gz --strip-components=1 "adminer-${ADMINER_VER}/designs/" "adminer-${ADMINER_VER}/plugins/"; \
    mkdir -p /var/www/html/plugins-enabled; \
    rm source.tar.gz

COPY --chown=wodby:wodby index.php /var/www/html

COPY entrypoint.sh /

EXPOSE 9000

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["php", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]

ARG BASE_IMAGE_TAG

FROM wodby/php:${BASE_IMAGE_TAG}

ARG ADMINER_VER

ENV ADMINER_VER="${ADMINER_VER}" \
    \
    PHP_MAX_EXECUTION_TIME=0 \
    PHP_POST_MAX_SIZE="512M" \
    PHP_UPLOAD_MAX_FILESIZE="512M"

RUN base_url="https://github.com/vrana/adminer"; \
    curl -sSL "${base_url}/releases/download/v${ADMINER_VER}/adminer-${ADMINER_VER}.php" -o adminer.php; \
    curl -sSL "${base_url}/archive/v${ADMINER_VER}.tar.gz" -o source.tar.gz; \
    tar xzf source.tar.gz --strip-components=1 "adminer-${ADMINER_VER}/designs/" "adminer-${ADMINER_VER}/plugins/"; \
    rm source.tar.gz

COPY index.php /var/www/html

EXPOSE 9000
CMD ["php", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]

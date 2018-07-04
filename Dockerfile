ARG BASE_IMAGE_TAG

FROM wodby/php:${BASE_IMAGE_TAG}

ARG ADMINER_VER
ARG ADMINER_LANG

ENV ADMINER_VER="${ADMINER_VER}" \
    ADMINER_LANG="${ADMINER_LANG:-en}" \
    \
    PHP_MAX_EXECUTION_TIME=0 \
    PHP_POST_MAX_SIZE="512M" \
    PHP_UPLOAD_MAX_FILESIZE="512M"

RUN ver="${ADMINER_VER}"; \
    url="https://github.com/vrana/adminer/releases/download/v${ver}/adminer-${ver}-mysql-${ADMINER_LANG}.php"; \
    curl -s -o /var/www/html/adminer.php -L "${url}"; \
    theme_url="https://raw.githubusercontent.com/vrana/adminer/master/designs/nicu/adminer.css"; \
    curl -s -o /var/www/html/adminer.css -L "${theme_url}"

COPY index.php /var/www/html

EXPOSE 9000
CMD ["php", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]

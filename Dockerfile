# check=skip=InvalidDefaultArgInFrom

# The Makefile supplies the required digest-pinned BASE_IMAGE argument: the
# Apache variant of wodby/php, which serves the application and runs PHP-FPM
# in one container. It already has the MySQL and PostgreSQL extensions.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG ADMINER_VER

ENV ADMINER_VER="${ADMINER_VER}" \
    \
    # Adminer reads its login defaults from the environment. \
    PHP_FPM_CLEAR_ENV="no" \
    PHP_MAX_EXECUTION_TIME=0 \
    PHP_MEMORY_LIMIT="512M" \
    PHP_POST_MAX_SIZE="512M" \
    PHP_UPLOAD_MAX_FILESIZE="512M" \
    # Long imports and exports run as long as PHP lets them. \
    APACHE_FCGI_PROXY_TIMEOUT="86400"

RUN set -ex; \
    cd /var/www/html; \
    base_url="https://github.com/vrana/adminer"; \
    curl -fsSL "${base_url}/releases/download/v${ADMINER_VER}/adminer-${ADMINER_VER}.php" -o adminer.php; \
    curl -fsSL "${base_url}/archive/v${ADMINER_VER}.tar.gz" -o /tmp/source.tar.gz; \
    curl -fsSL "https://github.com/TimWolla/docker-adminer/raw/98b870868bdd5adb179e79aa9b11cc01086ec1db/5/plugin-loader.php" -o plugin-loader.php; \
    tar xzf /tmp/source.tar.gz --strip-components=1 "adminer-${ADMINER_VER}/designs/" "adminer-${ADMINER_VER}/plugins/"; \
    mkdir -p plugins-enabled; \
    rm /tmp/source.tar.gz

COPY --chown=wodby:wodby index.php /var/www/html/
COPY init /docker-entrypoint-init.d/

# The container starts as root, like the earlier Apache-based image, so it also
# runs where privilege escalation is disallowed: the entrypoint and the Apache
# and PHP-FPM masters use sudo, which root doesn't need. Apache and PHP-FPM
# still serve requests as unprivileged users.
USER root

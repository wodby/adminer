FROM alpine:3.6

ENV ADMINER_VER 4.3.1

ENV ADMINER_URL https://github.com/vrana/adminer/releases/download/v${ADMINER_VER}/adminer-${ADMINER_VER}-mysql-en.php
ENV ADMINER_THEME_URL https://raw.githubusercontent.com/vrana/adminer/master/designs/nicu/adminer.css

RUN apk add --update --no-cache \
        bash \
        curl \
        php7 \
        php7-opcache \
        php7-session \
        php7-zlib \
        php7-mbstring \
        php7-pdo \
        php7-pdo_mysql \
        php7-mysqli && \

    sed -i \
        -e "s/^expose_php.*/expose_php = Off/" \
        -e "s/^;date.timezone.*/date.timezone = UTC/" \
        -e "s/^memory_limit.*/memory_limit = -1/" \
        -e "s/^max_execution_time.*/max_execution_time = 0/" \
        -e "s/^; max_input_vars.*/max_input_vars = 2000/" \
        -e "s/^post_max_size.*/post_max_size = 2048M/" \
        -e "s/^upload_max_filesize.*/upload_max_filesize = 2048M/" \
        -e "s/^error_reporting.*/error_reporting = E_ALL/" \
        -e "s/^display_errors.*/display_errors = On/" \
        -e "s/^display_startup_errors.*/display_startup_errors = On/" \
        -e "s/^track_errors.*/track_errors = On/" \
        /etc/php7/php.ini && \

    echo "error_log = \"/proc/self/fd/2\"" | tee -a /etc/php7/php.ini && \

    mkdir -p /var/www/html && \
    curl -s -o /var/www/html/adminer.php -L ${ADMINER_URL} && \
    curl -s -o /var/www/html/adminer.css -L ${ADMINER_THEME_URL}

COPY index.php /var/www/html

WORKDIR /var/www/html
EXPOSE 9000
CMD ["php7", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]

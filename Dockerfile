FROM alpine:3.5
MAINTAINER Wodby <admin@wodby.com>

RUN apk add --update --no-cache \
        bash \
        curl \
        php7 \
        php7-fpm \
        php7-opcache \
        php7-session \
        php7-pdo \
        php7-pdo_mysql \
        php7-zlib \
        php7-mysqli \
        php7-mbstring && \

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

    echo "error_log = \"/proc/self/fd/2\"" | tee -a /etc/php7/php.ini

ENV VERSION 4.2.5
ENV DESIGN nicu
LABEL version=$VERSION

RUN addgroup -g 82 -S www-data && \
    adduser -u 82 -D -S -G www-data www-data && \
    mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www && \
    curl -s -o /var/www/html/index.php -L https://github.com/vrana/adminer/releases/download/v${VERSION}/adminer-${VERSION}-en.php && \
    curl -s -o /var/www/html/adminer.css -L https://raw.githubusercontent.com/vrana/adminer/master/designs/${DESIGN}/adminer.css

WORKDIR /var/www/html
EXPOSE 9000
CMD ["php7", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]

USER www-data

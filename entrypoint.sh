#!/usr/bin/env bash

set -e

cd /var/www/html

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ -n "${ADMINER_DESIGN}" ]]; then
    install -m 0644 "designs/${ADMINER_DESIGN}/adminer.css" adminer.css
fi

if [[ -n "${ADMINER_PLUGINS}" ]]; then
    IFS=' ' read -r -a plugins <<< "${ADMINER_PLUGINS}"
    number=1

    for plugin in "${plugins[@]}"; do
        php plugin-loader.php "${plugin}" > "plugins-enabled/$(printf "%03d" "${number}")-${plugin}.php"
        number=$(($number+1))
    done
fi

exec docker-php-entrypoint "${@}"

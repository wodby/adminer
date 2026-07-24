#!/usr/bin/env bash

set -e

cd /var/www/html

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ -n "${ADMINER_DESIGN}" ]]; then
    design_path="designs/${ADMINER_DESIGN}"
    stylesheet_found=0

    for stylesheet in adminer.css adminer-dark.css; do
        if [[ -f "${design_path}/${stylesheet}" ]]; then
            install -m 0644 "${design_path}/${stylesheet}" "${stylesheet}"
            stylesheet_found=1
        fi
    done

    if [[ "${stylesheet_found}" -eq 0 ]]; then
        echo "No supported stylesheets found for Adminer design '${ADMINER_DESIGN}'" >&2
        exit 1
    fi
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

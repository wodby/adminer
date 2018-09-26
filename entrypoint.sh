#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

if [[ -n "${ADMINER_DESIGN}" ]]; then
	if [[  ! -e .adminer-init  ]]; then
		ln -sf "designs/${ADMINER_DESIGN}/adminer.css" .
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

touch .adminer-init || true

exec /docker-entrypoint.sh "${@}"
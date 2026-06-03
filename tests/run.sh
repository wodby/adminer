#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

cid="$(docker run -d -e DEBUG -e ADMINER_DESIGN=nette --name "${NAME}" "${IMAGE}")"
trap "docker rm -vf $cid > /dev/null" EXIT

echo -n "Checking adminer homepage... "
docker run --rm -i -e DEBUG --link "${NAME}" "${IMAGE}" sh -ec "curl -fsS \"${NAME}:80\" | grep -q Adminer && curl -fsS \"${NAME}:80\" | grep -q adminer.css"
echo "OK"

echo -n "Checking adminer theme CSS... "
docker run --rm -i -e DEBUG --link "${NAME}" "${IMAGE}" sh -ec "curl -fsS \"${NAME}:80/adminer.css\" | grep -q ."
echo "OK"

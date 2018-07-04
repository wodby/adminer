#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

cid="$(docker run -d -e DEBUG --name "${NAME}" "${IMAGE}")"
trap "docker rm -vf $cid > /dev/null" EXIT

echo -n "Checking adminer homepage... "
docker run --rm -i -e DEBUG --link "${NAME}" "${IMAGE}" sh -c "curl -s "${NAME}:9000" | grep -q Adminer"
echo "OK"
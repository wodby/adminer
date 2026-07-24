#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

cids=()
trap 'docker rm -vf "${cids[@]}" > /dev/null 2>&1' EXIT

for design_and_stylesheet in "nette adminer.css" "dracula adminer-dark.css"; do
    read -r design stylesheet <<< "${design_and_stylesheet}"
    container="${NAME}-${design}"
    cid="$(docker run -d -e DEBUG -e ADMINER_DESIGN="${design}" --name "${container}" "${IMAGE}")"
    cids+=("${cid}")

    echo -n "Checking adminer homepage with ${design} design... "
    docker run --rm -i -e DEBUG --link "${container}:adminer" "${IMAGE}" sh -ec "curl -fsS --retry 10 --retry-connrefused --retry-delay 1 'adminer:80' | grep -q Adminer && curl -fsS 'adminer:80' | grep -q '${stylesheet}'"
    echo "OK"

    echo -n "Checking ${design} design CSS... "
    docker run --rm -i -e DEBUG --link "${container}:adminer" "${IMAGE}" sh -ec "curl -fsS 'adminer:80/${stylesheet}' | grep -q ."
    echo "OK"
done

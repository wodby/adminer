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

# Exercise plugin generation and HTTP startup with more than one supported plugin.
container="${NAME}-plugins"
cid="$(docker run -d -e DEBUG -e ADMINER_PLUGINS="tables-filter edit-textarea" --name "${container}" "${IMAGE}")"
cids+=("${cid}")
echo -n "Checking adminer homepage with multiple plugins... "
docker run --rm -i --link "${container}:adminer" "${IMAGE}" sh -ec "curl -fsS --retry 10 --retry-connrefused --retry-delay 1 'adminer:80' | grep -q Adminer"
docker exec "${container}" sh -ec 'test -s plugins-enabled/001-tables-filter.php && test -s plugins-enabled/002-edit-textarea.php'
echo "OK"

# Missing plugins must fail before the requested container command is executed.
for plugin in tinymce nonexistent-plugin; do
    echo -n "Checking unavailable plugin ${plugin}... "
    if output="$(docker run --rm -e ADMINER_PLUGINS="tables-filter ${plugin}" "${IMAGE}" sh -c 'echo unexpected-startup' 2>&1)"; then
        echo "Unavailable plugin was accepted" >&2
        exit 1
    fi
    if ! grep -Fq "Adminer plugin '${plugin}' is not available" <<< "${output}" ||
        ! grep -Fq 'Correct or remove it from ADMINER_PLUGINS.' <<< "${output}" ||
        grep -Fq 'unexpected-startup' <<< "${output}"; then
        echo "${output}" >&2
        exit 1
    fi
    if [[ "${plugin}" == tinymce ]] && ! grep -Fq 'The TinyMCE plugin was removed upstream in Adminer 6.' <<< "${output}"; then
        echo "${output}" >&2
        exit 1
    fi
    echo "OK"
done

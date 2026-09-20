# Adminer Docker Container Image

[![Build Status](https://github.com/wodby/adminer/workflows/Build%20docker%20image/badge.svg)](https://github.com/wodby/adminer/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/adminer.svg)](https://hub.docker.com/r/wodby/adminer)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/adminer.svg)](https://hub.docker.com/r/wodby/adminer)

## Docker Images

Use image revision tags such as `wodby/adminer:6-rN` to select a Wodby image revision.
Major and minor tags use the repository release number, starting at `r0`. Full-version tags such as
`wodby/adminer:6.1.0-r0` start at `r0` for each exact upstream version.
Every published versioned revision tag has a matching annotated Git tag pointing to its release commit.
Existing tags remain available after support for their major or minor version ends.
See [release tags](https://github.com/wodby/adminer/tags) for available revisions and the [image revision policy](https://github.com/wodby/images#image-revisions) for upgrade guidance.
Previously published image tags remain available.

Overview:

- Base image: [php:8.4-apache](https://hub.docker.com/_/php)
- [GitHub actions builds](https://github.com/wodby/adminer/actions)  
- [Docker Hub](https://hub.docker.com/r/wodby/adminer)

Supported tags and respective `Dockerfile` links:

- `6.1`, `6`, `latest` [_(Dockerfile)_](https://github.com/wodby/adminer/tree/master/Dockerfile)

Plugin loader scripts used from [TimWolla/docker-adminer](https://github.com/TimWolla/docker-adminer).

All images built for `linux/amd64` and `linux/arm64`

## Environment Variables

| Variable                    | Default Value | Description                                             |
|-----------------------------|---------------|---------------------------------------------------------|
| `ADMINER_DEFAULT_DB_DRIVER` | `server`      | `server` is the same as `mysql`, `pgsql` for PostgreSQL |
| `ADMINER_DEFAULT_DB_HOST`   |               |                                                         |
| `ADMINER_DEFAULT_DB_NAME`   |               |                                                         |
| `ADMINER_DESIGN`            |               | Adminer theme, e.g. `nette`                             |
| `ADMINER_PLUGINS`           |               | Separated by space, e.g. `tables-filter`                |
| `PHP_CLI_MEMORY_LIMIT`      | `512M`        |                                                         |
| `PHP_MAX_EXECUTION_TIME`    | `0`           |                                                         |
| `PHP_POST_MAX_SIZE`         | `512M`        |                                                         |
| `PHP_UPLOAD_MAX_FILESIZE`   | `512M`        |                                                         |

See [wodby/php](https://github.com/wodby/php) for all variables

## Upgrading to Adminer 6

Review `ADMINER_PLUGINS` when upgrading from Adminer 5. Adminer 6 removed the
`tinymce`, `edit-calendar`, `json-column`, `pretty-json-column`, `translation`,
`email-table`, `dump-php`, and `master-slave` plugins
([upstream change](https://github.com/vrana/adminer/commit/7730d2e6dfc3831a8508e362bc8948dd0cd1bce2)).
Remove these names from your configuration; unavailable plugins stop container startup.
Removing `tinymce` also removes its rich-text editing functionality.

Space-separated plugin lists are still supported. For example:

```yaml
ADMINER_PLUGINS: tables-filter edit-textarea
```

## Deployment

Deploy Adminer to your own server via [![Wodby](https://www.google.com/s2/favicons?domain=wodby.com) Wodby](https://wodby.com).

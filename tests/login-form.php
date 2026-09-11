<?php

/** Check decoded login values and reject unescaped attribute delimiters. */
function checkField(string $html, string $name, string $expected): void {
    $attribute = preg_quote('auth[' . $name . ']', '~');
    if (!preg_match('~<input\b[^>]*\bname=([\"\'])' . $attribute . '\1[^>]*\bvalue=([\"\'])(.*?)\2~s', $html, $match)) {
        throw new RuntimeException("Missing login field: $name");
    }
    if (html_entity_decode($match[3], ENT_QUOTES, 'UTF-8') !== $expected) {
        throw new RuntimeException("Unexpected login value: $name");
    }
}

$host = getenv('ADMINER_DEFAULT_DB_HOST');
$db = getenv('ADMINER_DEFAULT_DB_NAME');
$html = file_get_contents('http://adminer/');
checkField($html, 'server', $host);
checkField($html, 'db', $db);
checkField($html, 'username', '');

// URL-provided values must take precedence over environment defaults.
$query = http_build_query(['server' => 'explicit-host', 'db' => 'explicit-db']);
$html = file_get_contents('http://adminer/?' . $query);
checkField($html, 'server', 'explicit-host');
checkField($html, 'db', 'explicit-db');
echo "OK\n";

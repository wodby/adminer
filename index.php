<?php

namespace docker {
    function adminer_object() {
        /**
         * Prefills login fields with the configured database defaults.
         */
        final class DefaultServerPlugin extends \Adminer\Plugin {
            public function __construct(
                private \Adminer\Adminer $adminer
            ) { }

            public function loginFormField(...$args) {
                return (function (...$args) {
                    $field = $this->loginFormField(...$args);

                    // Set default values via env vars.
                    $defaultDbDriver = getenv('ADMINER_DEFAULT_DB_DRIVER') ?: 'server';
                    $defaultDbHost = getenv('ADMINER_DEFAULT_DB_HOST') ?: '';
                    $defaultDb = getenv('ADMINER_DEFAULT_DB_NAME') ?: '';

                    $defaultDbDriver = $defaultDbDriver == 'mysql' ? 'server' : $defaultDbDriver;

                    // Adminer versions use different attribute quotes. Only fill empty values,
                    // and escape defaults for either quote style without changing explicit input.
                    $default = match ($args[0]) {
                        'server' => $defaultDbHost,
                        'db' => $defaultDb,
                        default => '',
                    };
                    if ($default !== '') {
                        $field = preg_replace_callback(
                            '~\bvalue=([\"\'])\\1~',
                            static fn ($match) => 'value=' . $match[1]
                                . htmlspecialchars($default, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')
                                . $match[1],
                            $field
                        );
                    }

                    echo str_replace(
                        [
                            'value="' . $defaultDbDriver . '"',
                            'selected="">MySQL'
                        ],
                        [
                            'value="' . $defaultDbDriver . '" selected="selected"',
                            '>MySQL'
                        ],
                        $field
                    );
                })->call($this->adminer, ...$args);
            }
        }

        $plugins = [];
        foreach (glob('plugins-enabled/*.php') as $plugin) {
            $plugins[] = require($plugin);
        }

        $adminer = new \Adminer\Plugins($plugins);

        (function () {
            $last = &$this->hooks['loginFormField'][\array_key_last($this->hooks['loginFormField'])];
            if ($last instanceof \Adminer\Adminer) {
                $defaultServerPlugin = new DefaultServerPlugin($last);
                $this->plugins[] = $defaultServerPlugin;
                $last = $defaultServerPlugin;
            }
        })->call($adminer);

        return $adminer;
    }
}

namespace {
    if (basename($_SERVER['DOCUMENT_URI'] ?? $_SERVER['REQUEST_URI']) === 'adminer.css' && is_readable('adminer.css')) {
        header('Content-Type: text/css');
        readfile('adminer.css');
        exit;
    }

    function adminer_object() {
        return \docker\adminer_object();
    }

    require('adminer.php');
}
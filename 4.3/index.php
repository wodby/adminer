<?php

function adminer_object() {

  class AdminerSoftware extends Adminer {
    function credentials() {
        $host = getenv('ADMINER_DB_HOST');
        $user = getenv('ADMINER_DB_USER');

        return array($host ? $host : 'localhost', $user ? $user : 'ODBC', '');
    }

    /**
     * Get key used for permanent login
     * @param bool
     * @return string
     */
    function permanentLogin($create = false) {
      if ($key = getenv('ADMINER_SALT')) {
        return $key;
      }
      else {
        return parent::permanentLogin($create);
      }
    }

  }

  return new AdminerSoftware;
}

include './adminer.php';

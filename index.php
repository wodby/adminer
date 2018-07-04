<?php

function adminer_object() {

  class AdminerSoftware extends Adminer {
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

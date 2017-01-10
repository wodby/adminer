<?php

if (!getenv('ADMINER_SESSID') && getenv('WODBY_INSTANCE_UUID')) {
  define('ADMINER_SESSID', str_replace('-', '', getenv('WODBY_INSTANCE_UUID')));
}

if (!defined("SID") && getenv('ADMINER_SESSID')) {
  session_name("adminer_sid_" . getenv('ADMINER_SESSID')); // use specific session name to get own namespace
  $HTTPS = $_SERVER["HTTPS"] && strcasecmp($_SERVER["HTTPS"], "off");
  $params = array(0, preg_replace('~\\?.*~', '', $_SERVER["REQUEST_URI"]), "", $HTTPS);
  if (version_compare(PHP_VERSION, '5.2.0') >= 0) {
    $params[] = true; // HttpOnly
  }
  call_user_func_array('session_set_cookie_params', $params); // ini_set() may be disabled
  session_start();
}

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

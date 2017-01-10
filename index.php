<?php

$adminer_ssid = getenv('ADMINER_SESSID');

if (!$adminer_ssid && getenv('WODBY_INSTANCE_UUID')) {
  $adminer_ssid = str_replace('-', '', getenv('WODBY_INSTANCE_UUID'));
}

if (!defined("SID") && $adminer_ssid) {
  session_name("adminer_sid_$adminer_ssid"); // use specific session name to get own namespace
  $HTTPS = !empty($_SERVER["HTTPS"]) && strcasecmp($_SERVER["HTTPS"], "off");
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

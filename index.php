<?php

function adminer_object() {

  class AdminerSoftware extends Adminer {
    // Place Adminer modifications here.
  }

  return new AdminerSoftware;
}

include './adminer.php';

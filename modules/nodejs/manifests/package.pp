# == Type: nodejs::package
#
# Manage nodejs packages.
#
# === Parameters:
#
# [*ensure*]
#  Translated directly into the state of installed/uninstalled
#  package.
#
# [*options*]
#  A list of zero or more options to install the package.
#
define nodejs::package (
  $ensure = 'present',
  $options = [],
) {

  if ensure_state($ensure) {
    $command = [
      "npm",
      "install", "--global",
      $options,
      $title,
    ]

    $onlyif = "test `npm view jsdoc version`"
  }
  else {
    $command = [
      "npm",
      "uninstall", "--global",
      $options,
      $title,
    ]

    $onlyif = "test ! `npm view jsdoc version`"
  }

  exec {"state_$title":
    path => ["/usr/bin"],
    command => shellquote($command),
    require => Package['nodejs'],
    onlyif => $onlyif,
  }
}


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

  $check_command = [
    "npm", "list",
    "--global",
    "--parseable",
    $name,
  ]

  if ensure_state($ensure) {
    $command = [
      "npm",
      "install", "--global",
      $options,
      $title,
    ]

    $onlyif = undef
    $unless = shellquote($check_command)
  }
  else {
    $command = [
      "npm",
      "uninstall", "--global",
      $options,
      $title,
    ]

    $onlyif = shellquote($check_command)
    $unless = undef
  }

  exec {"state_$title":
    path => ["/usr/bin"],
    command => shellquote($command),
    require => Package['nodejs'],
    onlyif => $onlyif,
    unless => $unless,
  }
}


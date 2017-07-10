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
      "install",
      $options,
      $title,
    ]

    $creates = "/usr/bin/${title}"
  }
  else {
    $command = [
      "npm",
      "uninstall",
      $options,
      $title,
    ]

    $creates = undef
  }

  exec {"state_$title":
    path => ["/usr/bin"],
    command => shellquote($command),
    require => Package['nodejs'],
    creates => $creates,
  }
}


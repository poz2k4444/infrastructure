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

  $command = [
    "npm",
    ensure_state($ensure) ? {
      true => 'install',
      false => 'uninstall',
    },
    $options,
    $title,
  ]

  if ensure_state($ensure) {
    exec {"install_$title":
      path => ["/usr/bin"],
      command => shellquote($command),
      require => Package['nodejs'],
      creates => "/usr/bin/${title}",
    }
  } else {
    exec {"uninstall_$title":
      path => ["/usr/bin"],
      command => shellquote($command),
      require => Package['nodejs'],
    }
  }
}
# == Type: nodejs::package
#
# Manage nodejs packages.
#
# === Parameters:
#
# [*options*]
#  A list of zero or more options to install the package.
#
define nodejs::package (
  $options = [],
) {

  $install_command = [
    "npm", "install",
    $options,
    $title,
  ]

  exec {"install_$title":
    path => ["/usr/bin"],
    command => shellquote($install_command),
    require => Package['nodejs'],
    onlyif => "test ! -x /usr/bin/${title}",
  }
}
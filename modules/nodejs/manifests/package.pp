define nodejs::package (
  $options = [],
  $provider = 'npm',
) {

  $install_command = [
    $provider,
    "install",
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
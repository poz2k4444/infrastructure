define nodejs::package (
  $global,
) {

  exec {"install_$title":
    path => ['/usr/bin/'],
    command => "npm install --global $title",
    require => Package['nodejs'],
    onlyif => "test ! -x /usr/bin/${title}",
  }
}
define nodejs::package (
  $global = true,
) {

  exec {"install_$title":
    path => ['/usr/bin/'],
    command => "npm install --global $title",
    require => Package['nodejs'],
  }
}
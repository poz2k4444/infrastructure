define nodejs::dependency (
  $global = true,
) {
  exec {"install_$title":
    path => ['/usr/bin/'],
    command => "npm install --global $title",
  }
}
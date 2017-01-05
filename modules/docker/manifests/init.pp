class docker(
  $source = hiera('docker::source', {}),
) {
  include stdlib

  ensure_resource('apt::source', 'docker', merge({
    before => Package['docker-engine'],
    location => 'https://apt.dockerproject.org/repo',
    release => downcase("$::osfamily-$::lsbdistcodename"),
    include_src => false,
    key => '58118E89F3A912897C070ADBF76221572C52609D',
    key_server => 'hkp://ha.pool.sks-keyservers.net:80',
  }, $source))

  package {'docker-engine':
    ensure => 'present',
    require => Apt::Source['docker'],
  }

  service {'docker':
    ensure => running,
    require => Package['docker-engine'],
  }
}


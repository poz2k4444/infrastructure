# Depends on module docker (for now)

class discourse_docker(
  $domain,
  $certificate = hiera('discourse_docker::certificate', undef),
  $private_key = hiera('discourse_docker::private_key', undef),
  $site_settings = hiera('discourse_docker::site_settings', {}),
  $is_default = hiera('discourse_docker::is_default', false),
  $admins = hiera('discourse_docker::admins', []),
  $google_oauth2_client_id = hiera('discourse_docker::google_oauth2_client_id', 'undef'),
  $google_oauth2_client_secret = hiera('discourse_docker::google_oauth2_client_secret', 'undef'),
) {

  include stdlib

  package {'git':
    ensure => present,
  }

  file {'/var/discourse':
    ensure => directory,
    mode => 755,
    owner => root,
    group => root
  }

  exec {'fetch-discourse-docker':
    command => "git clone https://github.com/discourse/discourse_docker.git /var/discourse",
    path => ["/usr/bin/", "/bin/"],
    user => root,
    timeout => 0,
    require => [Package['git'], File['/var/discourse']],
    unless => "test -d /var/discourse/.git"
  }

  file {'/var/discourse/containers/app.yml':
    ensure => file,
    mode => 600,
    owner => root,
    group => root,
    content => template('discourse_docker/app.yml.erb'),
    require => Class['docker'],
  }

  exec {'rebuild':
    command => '/var/discourse/launcher rebuild app --skip-prereqs',
    user => root,
    subscribe => File['/var/discourse/containers/app.yml'],
    refreshonly => true,
    logoutput => 'on_failure',
    timeout => 0,
    require => [Exec['fetch-discourse-docker'],
                Class['docker'],
                Package['git']],
  }

  exec {'start':
    command => '/var/discourse/launcher start app --skip-prereqs',
    user => root,
    logoutput => 'on_failure',
    require => Exec['rebuild'],
  }

  nginx::hostconfig {$domain:
    source => "puppet:///modules/discourse_docker/site.conf",
    certificate => $certificate,
    private_key => $private_key,
    is_default => $is_default,
    log => "access_log_intraforum"
  }
}

# == Class: adblockplus::crontab
#
# Maintain crontab(5) file.
#
# == Parameters:
#
# === Examples:
#
class adblockplus::crontab (
  $path = hiera('crontab::path', '/etc/crontab'),
  $vars = hiera_hash('crontab::vars', {}),
) {

  $variables = merge({
    'SHELL' => '/bin/sh',
    'PATH' => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    'MAILTO' => 'root,vagrant',
  }, $vars)

  file { $path:
    ensure => present,
    path => $path,
    content => template('adblockplus/crontab/crontab.erb'),
    owner => root,
    group => root,
    mode => 0644,
  }
}


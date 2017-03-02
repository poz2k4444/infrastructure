# == Class: geoip
#
# Manage GeoIP (http://dev.maxmind.com/geoip/) databases.
#
# === Parameters:
#
# [*cron*]
#   Default options for Cron['geoip'], e.g. $minute, $monthday etc.
#
# [*ensure*]
#   Either 'present', 'absent' or 'purged'.
#
# [*hook*]
#   A command to execute when Cron['geoip'] has succeeded, optional.
#
# [*packages*]
#   The names of the GeoIP packages.
#
# [*script*]
#   Where to store the update script executed by Cron['geoip'].
#
# [*version*]
#   A specific version to ensure for all $packages, optional.
#
# === Examples:
#
#   class {'geoip':
#     cron => {
#       'environment' => ['PYTHONPATH=/opt/custom'],
#       'minute' => 0,
#       'hour' => 8,
#       'monthday' => 15,
#     },
#   }
#
class geoip (
  $cron = hiera('geoip::cron', {}),
  $ensure = hiera('geoip::ensure', 'present'),
  $hook = hiera('geoip::hook', undef),
  $package = hiera('geoip::package', {}),
  $script = hiera('geoip::script', {
    path => '/usr/local/sbin/update-geoip-database',
  }),
  $version = undef,
) {

  notify{$script[path]:}

  ensure_resource('package', $title, merge({
    ensure => ensure_state($ensure),
  }, $package))

  ensure_resource('cron', $title, merge({
    command => $hook ? {undef => $script[path], default => "$script[path] && $hook"},
    ensure => $ensure ? {/^(absent|purged)$/ => 'absent', default => 'present'},
    hour => 0,
    minute => 0,
    user => 'root',
  }, $cron))

  ensure_resource('file', $title, merge({
    before => Cron[$title],
    ensure => ensure_file_state($ensure),
    mode => 0755,
    require => Package[$title],
    source => 'puppet:///modules/geoip/update.py',
  }, $script))
}


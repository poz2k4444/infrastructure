# == Class: adblockplus::log::archive
#
# Archive files after anonimizing them
# Establish monitoring for a single log-file source on the current node,
# connected to the adblockplus::log::forwarder output, if any.
#
# === Parameters:
#
class adblockplus::log::archive (
  $ensure = 'present',
  $directory = {},
  $script = {},
  $cron = {},
  $user = {},
  $log_salt = hiera('adblockplus::log::salt', 'changeme'),
) {

  ensure_resource('adblockplus::user', 'archive', merge({
    ensure => ensure_state($ensure),
    groups => ['adm', 'root'],
    name => 'archive',
  }, $user))

  ensure_resource('directory', '/var/log/archive', merge({
    ensure => ensure_directory_state($ensure),
    group => 'root',
  }, $directory))

  ensure_resource('file','/usr/local/bin/anonymize-access-log', merge({
    group => 'root',
    mode => '0755',
    owner => 'root',
    source => 'puppet:///modules/nginx/anonymize-access-log.py',
  }, $script))

  $cron_command = [
    'cat', '/var/log/nginx/access_log_easylist_downloads.1 |',
    '/usr/local/bin/anonymize-access-log',
    '--geolite2-city-db /usr/share/GeoIP/GeoLite2-City.mmdb',
    '--geolite-country-db /usr/share/GeoIP/GeoLite2-Country.mmdb',
    "--salt $log_salt |",
    "gzip -9 > /var/log/archive.`date +%Y-%m-%d`.`md5sum /var/log/nginx/access_log_easylist_downloads.1 |",
    "cut -d' ' -f1`.gz",
  ]

  ensure_resource('cron', 'archive_logs', merge({
    command => shellquote($cron_command),
    user    => 'root',
    hour    => 2,
    minute  => 0
  }, $cron))
}
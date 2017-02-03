# == Class: crontab
#
# Maintain crontab(5) file.
#
# == Parameters:
#
# === Examples:
#
class crontab (
  $path = hiera('crontab::path', '/etc/crontab'),
  $vars = hiera('crontab::vars', {
    'SHELL' => '/bin/sh',
    'PATH' => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    'MAILTO' => 'monitoring+cron@adblockplus.org',
  }),
  $jobs = hiera('crontab::jobs', [
    '17 *  * * * root cd / && run-parts --report /etc/cron.hourly',
    '0 0  * * * root test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )',
    '47 6  * * 7 root test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )',
    '52 6  1 * * root test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )',
  ]),
) {

  file { "crontab":
    ensure => present,
    path => $path,
    content => template('crontab/crontab.erb'),
    owner => root,
    group => root,
    mode => 0644,
  }
}


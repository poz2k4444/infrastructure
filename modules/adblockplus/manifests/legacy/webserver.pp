# == Class: adblockplus::legacy::webserver
#
# A container for migrating obsolete resources in web2, formerly located
# in manifests/webserver.pp.
#
# See http://hub.eyeo.com/issues/2007 for more information.
#
class adblockplus::legacy::webserver {
  $subscription_repo = '/home/www/subscriptionlist'

  $fetch_repo_cmd = [
    'hg', 'clone',
    '--noupdate',
    'https://hg.adblockplus.org/subscriptionlist',
    $subscription_repo,
  ]

  exec {'fetch_repository_subscriptionlist':
    command => shellquote($fetch_repo_cmd),
    path => '/usr/local/bin:/usr/bin:/bin',
    user => 'www',
    timeout => 0,
    onlyif => "test ! -d $subscription_repo",
    require => Package['mercurial'],
  }

  $update_repo_cmd = [
    'hg', 'pull',
    '--quiet', '--repository',
    $subscription_repo,
  ]

  cron {'update_repository_subscriptionlist':
    ensure => present,
    environment => hiera('cron::environment', []),
    command => shellquote($update_repo_cmd),
    user => 'www',
    minute => '1-59/20',
    require => Exec['fetch_repository_subscriptionlist']
  }

  $generate_docs_cmd = [
    'python', '-m',
    'sitescripts.docs.bin.generate_docs',
  ]

  cron {'generate_docs':
    ensure => 'present',
    require => [
      Class['sitescripts'],
      Exec['install_jsdoc'],
      Package['make', 'doxygen'],
      File['/var/www/docs'],
    ],
    command => shellquote($generate_docs_cmd),
    user => www,
    minute => '5-55/10',
  }
}


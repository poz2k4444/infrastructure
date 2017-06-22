class adblockplus::legacy::webserver {
  $sitescripts_var_dir = '/var/lib/sitescripts'
  $subscriptions_repo = "${sitescripts_var_dir}/subscriptionlist"

  user {'sitescripts':
    ensure => present,
    home => $sitescripts_var_dir
  }

  file {$sitescripts_var_dir:
    ensure => directory,
    mode => 0755,
    owner => 'sitescripts',
    group => 'sitescripts'
  }

  exec {'fetch_repository_subscriptionlist':
    command => "hg clone --noupdate https://hg.adblockplus.org/subscriptionlist $subscriptions_repo",
    path => '/usr/local/bin:/usr/bin:/bin',
    user => 'sitescripts',
    timeout => 0,
    onlyif => "test ! -d $subscriptions_repo",
    require => [Package['mercurial'], File[$sitescripts_var_dir]]
  }

  cron {'update_repository_subscriptionlist':
    ensure => present,
    environment => hiera('cron::environment', []),
    command => "hg pull --quiet --repository $subscriptions_repo",
    user => 'sitescripts',
    minute => '1-59/20',
    require => Exec['fetch_repository_subscriptionlist']
  }

  package {['make', 'doxygen']:}

  cron {'generate_docs':
    ensure => 'present',
    require => [
      Class['sitescripts'],
#      Exec['install_jsdoc'],
      Package['make', 'doxygen'],
      File['/var/www/docs'],
    ],
    command => 'python -m sitescripts.docs.bin.generate_docs',
    user => www,
    minute => '5-55/10',
  }

}
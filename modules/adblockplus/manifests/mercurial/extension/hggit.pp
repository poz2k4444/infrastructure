# == Class: adblockplus::mercurial::extension::hggit
#
# See http://hub.eyeo.com/issues/9024
# This class should be obsolete when puppet is => 4.1.0 due `install_options`
# being included for pip provider.
#
class adblockplus::mercurial::extension::hggit (
  $ensure = '0.8.9',
) {

  ensure_packages([
    'python-pip',
    'libffi-dev',
    'libssl-dev',
  ])

  exec {'upgrade setuptools':
    command => '/usr/bin/pip install --upgrade setuptools',
    require => Package['python-pip', 'libffi-dev', 'libssl-dev'],
  }

  exec {'upgrade urllib3':
    command => '/usr/bin/pip install --upgrade urllib3',
    require => Package['python-pip', 'libffi-dev', 'libssl-dev'],
  }

  adblockplus::mercurial::extension {'hggit':
    package => {
      ensure => $ensure,
      name => 'hg-git',
      provider => 'pip',
    },
    require => Exec['upgrade urllib3'],
  }
}
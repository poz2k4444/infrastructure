# == Class: adblockplus::proxy
#

# === Parameters:
#
# === Examples:
#
class adblockplus::proxy (
  $package = hiera('adblockplus::proxy::package', {})
) {

  if $package{
    ensure_resource('package', 'proxy', $package)
  }

  if $package[name] == 'squid3' {
      file {'/etc/squid3/squid.conf':
      ensure => present,
      group => 'root',
      mode => '0644',
      owner => 'root',
      content => template("adblockplus/squid.conf.erb"),
    }
  }
}


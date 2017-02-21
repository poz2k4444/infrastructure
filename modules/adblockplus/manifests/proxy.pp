# == Class: adblockplus::proxy
#
#
#
# === Parameters:
#
# [*ensure*]
#   Whether associated resources are meant to be 'present' or 'absent'.
#
# === Examples:
#
#   class {'adblockplus::sudo':
#     ensure => 'present',
#   }
#
class adblockplus::proxy(
    $vhost,
    $repository,
    $certificate = hiera('adblockplus::proxy::certificate', 'undef'),
    $private_key = hiera('adblockplus::proxy::private_key', 'undef'),
    $is_default = false,
    $aliases = undef,
    $custom_config = undef,
) {
  nginx::hostconfig {$vhost:
    content => template('adblockplus/proxy.erb'),
    global_config => template('adblockplus/proxy.erb'),
    is_default => $is_default,
    certificate => $certificate ? {'undef' => undef, default => $certificate},
    private_key => $private_key ? {'undef' => undef, default => $private_key},
    log => "access_log_$vhost"
  }
}
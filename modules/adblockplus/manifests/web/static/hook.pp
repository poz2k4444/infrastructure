# == Type: adblockplus::web::static::hook
#
# Manage custom hooks to be triggered via ssh commands
#
# === Parameters:
#
# [*file*]
#   Overwrite the default configuration for the hook.
#
# === Examples:
#
#  adblockplus::web::static::hook {'deploy':
#    'file' => {
#      source => 'puppet:///modules/adblockplus/web/deploy.py',
#      path => '/usr/local/bin/deploy.py',
#    },
#   }
#
#  adblockplus::web::static::hook {'uname':
#    'file' => {
#      content => 'uname -a',
#    },
#  }
#
define adblockplus::web::static::hook (
  $file = {},
) {

  ensure_resource('file', "hook#${name}", merge({
    mode => '0755',
    owner => $adblockplus::web::static::deploy_user,
    group => $adblockplus::web::static::deploy_user,
  }, $file, {
    ensure => ensure_file_state($adblockplus::web::static::ensure),
    path => "/home/$adblockplus::web::static::deploy_user/bin/${name}",
  }))
}


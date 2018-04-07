# == Type: adblockplus::web::static::hook
#
# Manage custom hooks to be triggered via ssh commands
#
# === Parameters:
#
# [*file*]
#   Overwrite group and the source of the content of the file.
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

  ensure_resource('file', "web-deploy-hook#${title}", merge({
    group => $adblockplus::web::static::deploy_user,
  }, $file, {
    mode => '0755',
    owner => $adblockplus::web::static::deploy_user,
    ensure => ensure_file_state($adblockplus::web::static::ensure),
    path => "/home/${adblockplus::web::static::deploy_user}/bin/${name}",
  }))
}


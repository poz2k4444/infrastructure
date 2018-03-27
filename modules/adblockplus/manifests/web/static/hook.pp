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
#    'own-uname' => {
#      content => 'uname -a',
#    },
#  }
#
define adblockplus::web::static::hook (
  $file = {},
) {

  File {
    mode => '0755',
    owner => $adblockplus::web::static::deploy_user,
    group => $adblockplus::web::static::deploy_user,
  }

  ensure_resource('file', "/usr/local/bin/commands", {
    ensure => ensure_file_state($adblockplus::web::static::ensure),
    source => 'puppet:///modules/adblockplus/web/static/commands.sh',
  })

  ensure_resource('file', "/home/$adblockplus::web::static::deploy_user/bin", {
    ensure => ensure_directory_state($adblockplus::web::static::ensure),
  })

  ensure_resource('file',
  "script#${name}",
  merge({
    ensure => ensure_file_state($adblockplus::web::static::ensure),
    path => "/home/$adblockplus::web::static::deploy_user/bin/${name}",
  }, $file))

}


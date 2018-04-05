# == Class: adblockplus::web::static
#
# Manage a simple Nginx-based webserver for static content
# that uses a customizable deployment script to e.g. fetch the content
# from a repository server (ref. http://hub.eyeo.com/issues/4523)
#
# === Parameters:
#
# [*domain*]
#   The domain name for the website.
#
# [*ssl_certificate*]
#   The name of the SSL certificate file within modules/private/files, if any.
#   Requires a private_key as well.
#
# [*ssl_private_key*]
#   The name of the private key file within modules/private/files, if any.
#   Requires a certificate as well.
#
# [*ensure*]
#   Whether to set up the website or not.
#
# [*deploy_user*]
#   User that will be used to issue commands.
#
# [*deploy_user_authorized_keys*]
#   Array of public keys that will have access to ssh commands
#
# [*hooks*]
#   Hash of adblockplus::web::static::hook items to set up in this context.
#
# === Examples:
#
#   class {'adblockplus::web::static':
#     domain => 'help.eyeo.com',
#     hooks => {
#       own-uname => {
#         file => {
#           content => 'uname -a',
#         }
#       }
#     },
#   }
#
class adblockplus::web::static (
  $domain,
  $ssl_certificate = undef,
  $ssl_private_key = undef,
  $ensure = 'present',
  $deploy_user = 'web-deploy',
  $deploy_user_authorized_keys = [],
  $hooks = {},
) {

  include adblockplus::web
  include nginx
  include geoip
  include ssh

  File {
    mode => '0755',
    owner => $deploy_user,
    group => $deploy_user,
  }

  ensure_resource('file', "/var/www/$domain", {
    ensure => ensure_directory_state($ensure),
    owner => 'www-data',
    group => 'www-data',
  })

  ensure_resource('nginx::hostconfig', $title, {
    content => template('adblockplus/web/static.conf.erb'),
    certificate => $ssl_certificate,
    domain => $domain,
    is_default => 'true',
    private_key => $ssl_private_key,
    log => "web.access.log",
  })

  $content = [
    "Match User ${deploy_user}",
    'AllowTcpForwarding no',
    'X11Forwarding no',
    'AllowAgentForwarding no',
    'GatewayPorts no',
    'ForceCommand /usr/local/bin/hooks_wrapper',
  ]

  create_resources('concat::fragment', {
  helpcenter => {
    content => join($content, "\n"),
    ensure => 'present',
    target => 'sshd_config',
    order => '20',
  }})

  ensure_resource('adblockplus::user', $deploy_user, {
    authorized_keys => $deploy_user_authorized_keys,
    ensure => $ensure,
    password_hash => '*',
    shell => '/bin/bash',
    groups => ['www-data'],
  })

  ensure_resource('file', "/usr/local/bin/hooks_wrapper", {
    ensure => ensure_file_state($ensure),
    content => template('adblockplus/web/hooks_wrapper.sh.erb'),
  })

  ensure_resource('file', "/home/$deploy_user/bin", {
    ensure => ensure_directory_state($ensure),
  })

  # https://docs.puppet.com/puppet/latest/function.html#createresources
  create_resources('adblockplus::web::static::hook', $hooks)
}


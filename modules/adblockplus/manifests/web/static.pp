# == Class: adblockplus::web::static
#
# Manage a simple Nginx-based webserver for static content
# that uses a customizable deployment script to e.g. fetch the content
# from a repository server (ref. http://hub.eyeo.com/issues/4523)
#
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
# === Examples:
#
#   class {'adblockplus::web::static':
#     domain => 'help.eyeo.com',
#   }
#
class adblockplus::web::static (
  $domain = undef,
  $ssl_certificate = undef,
  $ssl_private_key = undef,
  $ensure = 'present',
  $deploy_user = 'web-deploy',
  $deploy_user_authorized_keys = undef,
) {

  include adblockplus::web
  include nginx
  include geoip
  include ssh

  file {"/usr/local/bin/commands":
    ensure => ensure_file_state($ensure),
    source => 'puppet:///modules/adblockplus/web/static/commands.sh',
    mode => '0755',
    owner => $deploy_user,
    group => $deploy_user,
  }

  file {"/var/www/$domain":
    ensure => ensure_directory_state($ensure),
    mode => '0775',
    owner => www-data,
    group => www-data,
  }

  nginx::hostconfig {$title:
    content => template('adblockplus/web/static.conf.erb'),
    certificate => $ssl_certificate,
    domain => $domain,
    is_default => $is_default,
    private_key => $ssl_private_key,
    log => "access_log_$domain",
  }

  adblockplus::user {$deploy_user:
    authorized_keys => $deploy_user_authorized_keys,
    ensure => $ensure,
    password_hash => '*',
    shell => '/bin/bash',
    groups => ['www-data'],
  }

  file {"/home/$deploy_user/bin":
    ensure => ensure_directory_state($ensure),
    mode => '0755',
    owner => $deploy_user,
  }

  file {"/home/$deploy_user/deploy_script.py":
    source => 'puppet:///modules/adblockplus/web/static/deploy_script.py',
    ensure => $ensure,
    mode => '0755',
    owner => $deploy_user,
  }

}

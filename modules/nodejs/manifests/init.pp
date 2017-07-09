# == Class: nodejs
#
# Install nodejs package from source
#
# == Parameters:
#
# [*package*]
#   Overwrite the default package options, to fine-tune the target version (i.e.
#   ensure => 'latest') or remove nodejs (ensure => 'absent' or 'purged')
#
# [*key*]
#   Overwrite the default apt::key used (given Class['apt'] is defined).
#
# [*source*]
#   Overwrite the default apt::source used (given Class['apt'] is defined).
#
# [*packages*]
#   Adds adittional packages with npm.
#
# === Examples:
#
#   class {'nodejs':
#     package => {
#       ensure => 'latest',
#     },
#   }
#
#
class nodejs (
  $key = {
    key => '68576280',
    key_content => template("nodejs/nodesource.gpg.key.erb"),
  },
  $package = {},
  $source = {
    location => 'https://deb.nodesource.com/node_4.x',
    release => downcase($lsbdistcodename),
    repos => 'main',
  },
  $packages = {},
) {

  include stdlib

  ensure_resource('package', $title, merge({
    name => $title,
    require => Apt::Source[$title],
    ensure => $ensure,
  }, $package))

  # Used as default $ensure parameter for most resources below
  $ensure = getparam(Package[$title], 'ensure') ? {
    /^(absent|purged)$/ => 'absent',
    default => 'present',
  }

  if ensure_state($ensure) {

    # The only package provider recognized implicitly
    ensure_resource('apt::key', $title, merge({
      ensure => $ensure,
      name => 'nodesource',
    }, $key))

    ensure_resource('apt::source', $title, merge({
      ensure => $ensure,
      include_src => false,
      name => 'nodesource',
    }, $source))

    Apt::Source[$title] <- Apt::Key[$title]
    Apt::Source[$title] -> Package[$title]

    create_resources('nodejs::package', $packages)

  }

}
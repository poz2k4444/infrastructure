# == Class: nodejs
#
# Install nodejs package from source
#
# == Parameters:
#
# === Examples:
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
  $dependencies = {},
) {

  include stdlib

  ensure_resource('package', $title, merge({
    name => $title,
    require => Apt::Source[$title],
  }, $package))

  # Used as default $ensure parameter for most resources below
  $ensure = getparam(Package[$title], 'ensure') ? {
    /^(absent|purged|held)$/ => 'absent',
    default => 'present',
  }

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

  notify{$dependencies:}

  create_resources('nodejs::dependency', $dependencies)
}
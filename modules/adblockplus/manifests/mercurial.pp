# == Class: adblockplus::mercurial
#
# Manage Mercurial (https://www.mercurial-scm.org/) resources.
#
# === Parameters:
#
# === Examples:
#
#   class {'adblockplus::mercurial':
#     ensure => 'latest',
#   }
#
class adblockplus::mercurial (
  $config = {},
  $extensions = {},
  $package = {},
) {

  # https://forge.puppet.com/puppetlabs/stdlib
  include stdlib

  # https://forge.puppet.com/puppetlabs/stdlib#ensure_resource
  ensure_resource('package', 'mercurial', $package)

  # https://forge.puppet.com/puppetlabs/stdlib#getparam
  $package_ensure = getparam(Package['mercurial'], 'ensure')

  # https://docs.puppet.com/puppet/latest/lang_conditional.html#selectors
  $ensure = $package_ensure ? {
    /^(absent|latest|present|purged|true)$/ => $package_ensure,
    default => 'present',
  }

  # https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-content
  # https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-source
  $default_content = $config['source'] ? {
    undef => template('adblockplus/mercurial/hgrc.erb'),
    default => undef,
  }

  # https://forge.puppet.com/puppetlabs/stdlib#merge
  ensure_resource('file', 'hgrc', merge({
    'ensure' => ensure_file_state(Package['mercurial']),
    'group' = 'root',
    'mode' => '0644',
    'owner' => 'root',
    'path' => '/etc/mercurial/hgrc',
    'source' => $default_source,
  }, $config))

  # https://docs.puppet.com/puppet/latest/lang_relationships.html
  Package['mercurial'] -> File['hgrc']

  # https://docs.puppet.com/puppet/latest/function.html#createresources
  create_resources('adblockplus::mercurial::extension', $extensions)
}

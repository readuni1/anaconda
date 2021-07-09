# @summary Parameters class.
#
class anaconda::params {

  $base_url = lookup('anaconda::base_url')

  $base_path = lookup('anaconda::base_path')
  $anaconda_install_version = lookup('anaconda::install_version')

  #should x86_64 be replaced by ${facts['hardware']} ?
  $installer = $::kernel ? {
    /(L|l)inux/ => "Anaconda3-${anaconda_install_version}-Linux-x86_64.sh",
    'windows'   => "Anaconda-${anaconda_install_version}-Windows-x86_64.exe",
    'Darwin'    => "Anaconda3-${anaconda_install_version}-MacOSX-x86_64.sh",
  }

  #TODO: add support for other versions

  $url = "${base_url}/${installer}"
}



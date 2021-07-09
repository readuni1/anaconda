# @summary Manages the installation of anaconda.
#
class anaconda::install {

  include anaconda::params

  # Bug fix: the require will force a download even if it
  # doesn't have to be installed
  exec { 'install_anaconda':
    command => "bash /tmp/${anaconda::params::installer} -b -p ${anaconda::params::base_path}",
    creates => $anaconda::params::base_path,
    timeout => 0,
    require => Exec['download_anaconda'],
  }

  # Bug fix: the onlyif prevents the download from happening
  # when it doesn't need to be installed
  # Avoid circular dependency on "install_anaconda", run if /opt/anaconda
  # doesn't exist
  exec { 'download_anaconda':
    command => "wget -P /tmp ${anaconda::params::url}",
    creates => "/tmp/${anaconda::params::installer}",
    onlyif  => "test ! -d ${anaconda::params::base_path}",
    timeout => 0,
  }

  file { "${anaconda::params::base_path}/.condarc":
    ensure  => present,
    source  => 'puppet:///modules/anaconda/.condarc',
    require => Exec['install_anaconda'],
  }

  exec{ 'install_conda_build':
    command => '/opt/anaconda/bin/conda install conda-build',
    creates => '/opt/anaconda/bind/conda-build',
    timeout => 0,
    require => File[ '/opt/anaconda/.condarc'],
  }
}

# Manages the installation of anaconda.
class anaconda::install {

#  include anaconda::params

  # Bug fix: the require will force a download even if it
  # doesn't have to be installed
  exec { 'install_anaconda':
    command => "bash /tmp/${anaconda::installer} -b -p ${anaconda::base_path}",
    creates => $anaconda::base_path,
    require => Exec['download_anaconda'],
  }

  # Bug fix: the onlyif prevents the download from happening
  # when it doesn't need to be installed
  # Avoid circular dependency on "install_anaconda", run if /opt/anaconda
  # doesn't exist
  exec { 'download_anaconda':
    command => "wget -P /tmp ${anaconda::base_url}/${anaconda::installer}",
    creates => "/tmp/${anaconda::installer}",
    onlyif  => "test ! -d ${anaconda::base_path}",
  }

  file { "${anaconda::base_path}/.condarc":
    ensure  => present,
    source  => 'puppet:///modules/anaconda/.condarc',
    require => Exec['install_anaconda'],
  }
}

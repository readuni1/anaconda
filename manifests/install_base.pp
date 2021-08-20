# Manages the installation of anaconda.
define anaconda::install_base (
  String $ensure = 'installed',
  String $anaconda_version,
  String $installer,
) {

#  include anaconda::params
  $path = "${anaconda::base_path}/${anaconda_version}"
  if ( $ensure == 'absent' ) {
    exec { "remove_anaconda_${anaconda_version}":
      command => "rm -rf ${path}",
      onlyif  => "test -d ${path}",
    }
    exec { "remove_anaconda_download_${anaconda_version}":
      command => "rm ${installer}",
      onlyif  => "test -e ${installer}",
    }
  } else {
    # Bug fix: the require will force a download even if it
    # doesn't have to be installed
    exec { "install_anaconda_${anaconda_version}":
      command => "bash /tmp/${installer} -b -p ${path}",
      creates => $path,
      require => Exec["download_anaconda_${anaconda_version}"],
    }
  
    # Bug fix: the onlyif prevents the download from happening
    # when it doesn't need to be installed
    # Avoid circular dependency on "install_anaconda", run if /opt/anaconda
    # doesn't exist
    exec { "download_anaconda_${anaconda_version}":
      command => "wget -P /tmp ${anaconda::base_url}/${installer}",
      creates => "/tmp/${installer}",
      onlyif  => "test ! -d ${path}",
    }
  
  #  file { "${path}/.condarc":
  #    ensure  => present,
  #    source  => 'puppet:///modules/anaconda/.condarc',
  #    require => Exec["install_anaconda_${anaconda_version}"],
  #  }
  }
}

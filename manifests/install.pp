# Manages the installation of anaconda.
define anaconda::install (
  String $ensure = 'installed',
  String $anaconda_version,
  Hash   $config = {},
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
    $installer=$::anaconda::installer
    $envs_hash = $config['envs'] ? {
      undef   => $anaconda::default_envs,
      default => $anaconda::default_envs + $config['envs'],
    }
    $channels_hash = $config['channels'] ? {
      undef   => $anaconda::default_channels,
      default => $anaconda::default_channels + $config['channels'],
    }
    anaconda::install_base { "anaconda3_${anaconda_version}":
      ensure => $config['ensure'],
      installer => $installer,
      anaconda_version => $anaconda_version,
      require => File[$anaconda::base_path],
    }

    $channels_hash.each |String $channel_name, Hash $channel_hash| {
      anaconda::channel { "anaconda3_${anaconda_version}_channel_${channel_name}":
        anaconda_version => $anaconda_version,
        channel          => $channel_hash['channel'],
        action           => $channel_hash['action'],
        exec_timeout     => $channel_hash['exec_timeout'],
      }
    }
    $envs_hash.each |String $env_name, Hash $env_hash| {
      $packages = $env_hash['packages'] ? {
        Undef   => '',
        Array   => join($env_hash['packages'],' '),
        String  => $env_hash['packages'],
        default => "${env_hash['packages']}",
      }
      anaconda::env { "anaconda3_${anaconda_version}_env_${env_name}":
        anaconda_version => $anaconda_version,
        env_name         => $env_name,
        language         => $env_hash['language'],
        python_version   => $env_hash['python_version'],
        packages         => $packages,
        exec_timeout     => $env_hash['exec_timeout'],
      }
    }
  }

}

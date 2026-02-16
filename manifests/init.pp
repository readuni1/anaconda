# Manages the installation of anaconda.
class anaconda (
  Variant[String,Float] $default_anaconda_version,
  Variant[String,Float] $default_env_python_version,
  String                $base_path,
  String                $base_url,
  String                $installer             = '',
  Array                 $depend_pkgs,
  String                $default_env_language = 'python',
  Hash                  $configs              = {},
  Hash                  $default_envs         = {},
  Hash                  $default_channels     = {},
  Integer               $exec_timeout         = 300,
) {
#  include anaconda::params
  Exec { path => "${anaconda::base_path}/bin:/usr/bin:/usr/sbin/:/bin:/sbin" }
  stdlib::ensure_packages ( $depend_pkgs,
    {
      ensure  => 'installed',
    }
  )
  file { $base_path:
    ensure => 'directory'
  }
#  unless $default_config['python_version'] {
#    $default_config['python_version'] = $default_python_version
#  }
  $configs.each |String $anaconda_version, Hash $config| {
    anaconda::install { "anaconda3_${anaconda_version}":
      ensure => $config['ensure'],
      anaconda_version => $anaconda_version,
      config  => $config,
      require => File[$base_path],
    }
  }
  unless $configs[$default_anaconda_version] {
    anaconda::install { "anaconda3_${default_anaconda_version}":
      anaconda_version => $default_anaconda_version,
      require => File[$base_path],
    }
  }

  #make sure channels are configured before envs
  Anaconda::Channel <| |> -> Anaconda::Env <| |>
}

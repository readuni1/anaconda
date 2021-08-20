# Adds packages to an existing Conda env
# Need to add Version parameter

# Note: This can be very slow - it downloads packages from the Repo

define anaconda::package(
  String $pkg_name = $title,
  Optional[String] $env_name,
  Optional[String] $language,
  String $base_path = $anaconda::base_path,
  Optional[String] $package_version,
  String $anaconda_version = $anaconda::default_anaconda_version,
  Optional[Integer] $exec_timeout,
) {
  include anaconda

  $conda = "${anaconda::base_path}/${anaconda_version}/bin/conda"

  # Need environment option if env is set
  # Also requirement on the env being defined
  if $env_name {
    $env_option = "--name ${env_name}"
    $env_require = [
      Anaconda::Install_base["anaconda3_${anaconda_version}"],
      Anaconda::Env["anaconda3_${anaconda_version}_env_${env_name}"]
    ]
    $_env_name = $env_name
  } else {
    $env_option  = ''
    $_env_name    = 'base'
    $env_require = [Anaconda::Install_base["anaconda3_${anaconda_version}"]]
  }

  $def_hash = { 
    'language'     => 'anaconda::default_env_language',
    'exec_timeout' => 'anaconda::default_exec_timeout',
  }
  $config_hash = $anaconda::configs[$anaconda_version]
  $def_env_hash = $anaconda::default_envs[$_env_name]

  if $config_hash {
    $config_envs_hash = $config_hash[$env_name]
    if $config_envs_hash {
      $config_env_hash = $config_envs_hash[$_env_name]
      if $config_env_hash {
        $_def_hash = $def_hash + $config_hash + $def_env_hash
      } else {
        $_def_hash = $def_hash + $config_hash
      }
    } else {
      $_def_hash = $def_hash
    }
  } else {
    $_def_hash = $def_hash
  }

  $_language = $language ? {
    undef  => $_def_hash['language'],
    default=> $language,
  }
  $_exec_timeout = $exec_timeout ? {
    undef  => $_def_hash['exec_timeout'],
    default=> $exec_timeout,
  }

  case $language {
    'r', 'R'           : { $options = '-c r' }
    'python', 'Python' : { $options = '' }
    default:             { $options = '' }
  }

  if $package_version {
    $vchkcmd = "| grep -q '${package_version}'"
  } else {
    $vchkcmd = ''
  }

  exec { "anaconda3_${anaconda_version}_env_${_env_name}_${pkg_name}":
      command =>
      "${conda} install --yes --quiet ${env_option} ${options} ${pkg_name}",
      require => $env_require,
      timeout => $exec_timeout,

      # Ugly way to check if package is already installed
      # bug: conda list returns 0 no matter what so we grep output
      unless  => "${conda} list ${env_option} ${pkg_name} | grep -q -w -i '${pkg_name}' ${vchkcmd}",
  }
}

# Adds packages to an existing Conda env
# Need to add Version parameter

# Note: This can be very slow - it downloads packages from the Repo

define anaconda::package(
  $env       = undef,
  $language  = 'python',
  $base_path = $anaconda::base_path,
  $version   = undef,
) {
  include anaconda

  $conda = "${anaconda::base_path}/bin/conda"

  case $language {
    'r', 'R'           : { $options = '-c r' }
    'python', 'Python' : { $options = '' }
    default:             { $options = '' }
  }

  # Need environment option if env is set
  # Also requirement on the env being defined
  if $env {
      $env_option = "--name ${env}"
      $env_require = [Class['anaconda::install'], Anaconda::Env[$env] ]
      $env_name = $env
  } else {
      $env_option  = ''
      $env_name    = 'root'
      $env_require = [Class['anaconda::install']]
  }

  if $version {
    $vchkcmd = "| grep -q '${version}'"
  } else {
    $vchkcmd = ''
  }

  exec { "anaconda_${env_name}_${name}":
      command =>
      "${conda} install --yes --quiet ${env_option} ${options} ${name}",
      require => $env_require,

      # Ugly way to check if package is already installed
      # bug: conda list returns 0 no matter what so we grep output
      unless  => "${conda} list ${env_option} ${name} | grep -q -w -i '${name}' ${vchkcmd}",
  }
}

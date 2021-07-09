# @summary Adds packages to an existing Conda env
#
# @note Need to add Version parameter.
#       This can be very slow - it downloads packages from the Repo
#
# @param env
#   The environment to install the package.
#
# @param language
#   The language to use to install the package.
#
# @param base_path
#   The base path to anaconda.
#
# @param timeout
#   The puppet exec resource timeout parameter.
#   @see https://puppet.com/docs/puppet/latest/types/exec.html#exec-attribute-timeout
#
define anaconda::package(
  String  $env       = undef,
  String  $language  = 'python',
  String  $base_path = '/opt/anaconda',
  Integer $timeout   = 0,
){
  include anaconda

  $conda = "${base_path}/bin/conda"

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

  exec { "anaconda_${env_name}_${name}":
      command => "${conda} install --yes --quiet ${env_option} ${options} ${name}",
      timeout => $timeout,
      require => $env_require,

      # Ugly way to check if package is already installed
      # bug: conda list returns 0 no matter what so we grep output
      unless  => "${conda} list ${env_option} ${name} | grep -q -w -i '${name}'",
  }
}

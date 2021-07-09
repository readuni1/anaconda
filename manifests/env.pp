# @summary Creates an environment with Anaconda, Python, and Numpy
#
# @param language
#   The language to install.
#   Options:
#   * r
#   * python
#
# @param version
#   The language version to use.
#
# @param anaconda_version
#   The version of anaconda to use.
#
# @param base_path
#   The path to anaconda.
#
# @param exec_timeout
#   The timeout to setup the environment.
#
# @param environment_file
#   Create an environment using the environment file.
#   @see https://tinyurl.com/y5yytuzh
#
define anaconda::env(
  Optional[String] $language         = undef,
  String           $version          = lookup('anaconda::python_version'),
  String           $anaconda_version = lookup('anaconda::anaconda_version'),
  String           $base_path        = lookup('anaconda::base_path'),
  String           $exec_timeout     = '300'
  Optional[String] $environment_file = undef,
){

  include anaconda

  $conda = "${base_path}/bin/conda"

  case $language {
    'r', 'R'           : { $options = '-c r' }
    'python', 'Python' : { $options = "python=${version}" }
    default:             { $options = "python=${version}" }
  }

  if $environment_file {
    $command = "${conda} env create --quiet --name=${name} anaconda=${anaconda_version} -f ${environment_file}"
  }else{
    $command = "${conda} create --yes --quiet --name=${name} anaconda=${anaconda_version} ${options}"
  }

  exec{ "anaconda_env_${name}":
      command => $command,
      creates => "${base_path}/envs/${name}",
      timeout => $exec_timeout,
      require => Class['anaconda::install'],
  }
}

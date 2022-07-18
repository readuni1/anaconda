# Creates an environment with Anaconda, Python, and Numpy
# To add packages see anaconda::package


define anaconda::env(
  String            $env_name         = $title,
  Optional[String]  $language         = undef,
  Optional[String]  $python_version,
  String            $anaconda_version = $anaconda::default_anaconda_version,
  String            $base_path        = $anaconda::base_path,
  String            $packages         = '',
  Optional[Integer] $exec_timeout,
) {

  anchor{"anaconda::${anaconda_version}::env::${title}::begin":}
  include anaconda

  $def_hash = { 
    'python_version' => $anaconda::default_env_python_version,
    'language'       => $anaconda::default_env_language,
    'exec_timeout'   => $anaconda::exec_timeout,
  }
  $configs_hash = $anaconda::configs[$anaconda_version]
  $_def_hash = $configs_hash ? {
    undef   => $def_hash,
    default => $def_hash + $configs_hash,
  }
  $conda = "${anaconda::base_path}/${anaconda_version}/bin/conda"
  $_python_version = $python_version ? {
    undef  => $_def_hash['python_version'],
    default=> $python_version,
  }
  $_language = $language ? {
    undef  => $_def_hash['language'],
    default=> $language,
  }
  $_exec_timeout = $exec_timeout ? {
    undef  => $_def_hash['exec_timeout'],
    default=> $exec_timeout,
  }

  case $_language {
    'r', 'R'           : { $options = '-c r' }
    'python', 'Python' : { $options = "python=${_python_version}" }
    default:             { $options = "python=${_python_version}" }
  }

  exec { "anaconda3_${anaconda_version}_env_${env_name}":
    command => "${conda} create --yes --quiet \
                    --name=${env_name} anaconda=${anaconda_version} \
                    ${options} ${packages}",
    creates => "${base_path}/${anaconda_version}/envs/${env_name}",
        timeout => $_exec_timeout,
        require => Anaconda::Install_base["anaconda3_${anaconda_version}"],
  }

  anchor{"anaconda::${anaconda_version}::env::${title}::end":
    require => Exec["anaconda3_${anaconda_version}_env_${env_name}"],
  }
}

# Defined Type: anaconda::channel
# Adds a channel to the anaconda environment
#
#
# [Required Parameters]
# * `channel`
#   The channel to add.
#
# * `env`
#   The environment to add the channel to.
#

define anaconda::channel(
  String $channel          = $title,
  String $anaconda_version = $anaconda::default_anaconda_version,
  String $base_path        = $anaconda::base_path,
  Optional[String]  $action,
  Optional[Integer] $exec_timeout,
) {

  anchor{"anaconda::${anaconda_version}::channel::${title}::begin":
    require => Anaconda::Install_base["anaconda3_${anaconda_version}"],
  }

  include anaconda

  $conda = "${anaconda::base_path}/${anaconda_version}/bin/conda"

  $_exec_timeout = $exec_timeout ? {
    undef  => $anaconda::exec_timeout,
    default=> $exec_timeout,
  }
  $_action = $action ? {
    undef  => 'add',
    default=> $action,
  }

  exec { "anaconda3_${anaconda_version}_channel_${channel}":
    command => "${conda} config --${_action} channels ${channel}",
    require => Anchor["anaconda::${anaconda_version}::channel::${title}::begin"],
    unless  => "${conda} config --show channels | grep -q -w -i ${channel}",
    timeout => $_exec_timeout,
  }

  anchor{"anaconda::${anaconda_version}channel::${title}::end":
    require => Exec["anaconda3_${anaconda_version}_channel_${channel}"],
  }
}

# @summary Adds a channel to the anaconda environment
#
# @param channel
#   The channel to add.
#
# @param env
#   The environment to add the channel to.
#
define anaconda::channel(
  String $channel   = $title,
  String $base_path = lookup(anaconda::base_path),
) {

  include anaconda
  $conda   = "${base_path}/bin/conda"
  $command = "${conda} config --add channels ${channel}"

  #conda env create -f pof.yml
  exec { "anaconda_channel_${name}":
    command => $command,
    unless  => "${conda} config --get channels | grep -q -w -i ${name}",
  }
}

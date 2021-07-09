# @summary Manages the installation of anaconda.
class anaconda {
  include anaconda::params
  Exec { path => "${anaconda::params::base_path}/bin:/usr/bin:/usr/sbin/:/bin:/sbin" }
  include anaconda::install
}

# Manages the installation of anaconda.
class anaconda (
  String $python_version,
  String $anaconda_version,
  String $install_version,
  String $base_path,
  String $base_url,
  Array  $depend_pkgs,
) {
  include anaconda::params
  Exec { path => "${anaconda::params::base_path}/bin:/usr/bin:/usr/sbin/:/bin:/sbin" }
  include anaconda::install
  ensure_packages ( $depend_pkgs,
    {
      ensure  => 'installed',
    }
  )

}

# == Class: rundeck_rd_winrm_plugin::install
#
class rundeck_rd_winrm_plugin::install (
  $rd_winrm_plugin_version  = $rundeck_rd_winrm_plugin::plugin_version,
  $rundeck_plugins_dir      = $rundeck_rd_winrm_plugin::rundeck_plugins_dir,
  $rundeck_user             = $rundeck_rd_winrm_plugin::rundeck_user,
  $rundeck_group            = $rundeck_rd_winrm_plugin::rundeck_group,
  $rd_winrm_plugin_packages = $rundeck_rd_winrm_plugin::rd_winrm_plugin_packages,
) {

  if !defined(Class['rundeck_rd_winrm_plugin']) {
    fail("Error: Class['rundeck_rd_winrm_plugin'] must be declared before Class['rundeck_rd_winrm_plugin::install'].")
  }

  # Install required OS packages
  $rd_winrm_plugin_packages.each |$pkg| {
    if ! defined(Package[$pkg]) {
      package { $pkg :
        ensure => present,
        before => File['download winrm ruby gems'],
      }
    }
  }

  # Download winrm ruby gems and dependencies
  file { 'download winrm ruby gems':
    ensure => directory,
    path   => $rundeck_rd_winrm_plugin::params::local_tmp_gems_dir,
    source => "puppet:///modules/${module_name}/gems",
  }->

  # Install winrm ruby gems and dependencies
  exec { 'install winrm ruby gems':
    command => 'for GEM in $(ls *.gem) ; do ; gem install $GEM --local --force --ignore-dependencies --no-ri --no-rdoc ; done',
    cwd     => $rundeck_rd_winrm_plugin::params::local_tmp_gems_dir,
    unless  => "/usr/bin/test -f ${plugin_dir}/rd-winrm-plugin-${rd_winrm_plugin_version}.zip",
  }->

  # Copy plugin to Rundeck plugins directory
  file { 'download rd-winrm-plugin zip file':
    ensure => present,
    path   => "${rundeck_plugins_dir}/rd-winrm-plugin-${rd_winrm_plugin_version}.zip",
    source => "puppet:///modules/${module_name}/plugins/rd-winrm-plugin-${rd_winrm_plugin_version}.zip",
    owner  => $user,
    group  => $group,
  }
}
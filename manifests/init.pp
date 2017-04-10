# Class sonarqube
#
# Description
# This module installs and manages Sonarqube installation.
# By default the installation is done using the sonarqube archive.
# When setting the *use_package* parameter to 'true', a package based 
# installation is performed. With this installation, this mosule does not
# manage a seperate home dir for the sonar user.
#
# Parameters
#
# [*version*]
#   Version of sonarqube to install. Check the version format when installing
#   from archive or from package
#   Default: 4.5.7
# [*user*]
#   User to run sonarqube server as
#   Default: sonar
#
# [*group*]
#   Group to run sonarqube server as
#   Default: Sonar
#
# [*user_system*]:
#   Should the sonar user and group be handles as a system user ? (true, false)
#   Default: true
#
# [*service*]
#   Name of the service
#   Default: sonar
#
# [*installroot*]
#   Base directory where to install the sonarqube binary
#
# [*home*]
#   Home directory of the sonar user.  Only used when installing from archive.
#   'data', 'extras', 'extensions', 'logs' subdirectory form the arcive will be 
#   moved in this home directory.
#   Default: /var/local/sonar
#
# [*host*]
# Thhe host/ipaddress of the sonarqube webservice.  Used in the sonar.properties template.
# Default: undef
#
# [*port*]
#   Port to run the service on. Used in the sonar.properties template.
#   Default: 9000
#
# [*portAjp*]
#   Used in the sonar.properties template.
#   Default: -1
#
# [*download_url*]
#   URL to download sonarqube archive from.
#   Default: https://sonarsource.bintray.com/Distribution/sonarqube
#
# [*download_dir*]
#   where to save the sonarqube archive
#   Default: /tmp
#
# [*context_path*]
#   Used in the sonar.properties template.
#   Default: undef
#
# [*arch*]
#   Architechture as $::kernel-$::architechture. e.g. linux-x86-64
#   Default: see sonarqube::params
#
# [*https*]
#   Used in the sonar.properties template.
#   Default: {} 
#
# [*ldap*]
#   Used in the sonar.properties template.
#   ldap and pam are mutually exclusive. Setting $ldap will annihilate the setting of $pam
#   Default: {}
#
# [*pam*]
#   Used in the sonar.properties template.
#   ldap and pam are mutually exclusive. Setting $ldap will annihilate the setting of $pam
#   Default: {}
#
# [*crowd*]
#   Used in the sonar.properties template.
#   Default: {}
#
# [*jdbc*]
#   Java database connection information
#
# [*log_folder*]
#   where to save logs. Used in the logback.xml template.
#   Default: $home/logs
#
# [*updatecenter*]
#    Used in the sonar.properties template. Boolean
#    Default: true
#
# [*http_proxy*]
#   Used in the sonar.properties template.
#   Default: {}
#
# [*https_proxy*]
#   Used in the sonar.properties template.
#   Default: {}
#
# [*web_java_opts*]
#   Used in the sonar.properties template.
#   Default: undef
#
# [*search_java_opts*]
#   Used in the sonar.properties template.
#   Default: undef
#
# [*search_host*]
#   Used in the sonar.properties template.
#   Default: 127.0.0.1
#
# [*search_port*]
#   Used in the sonar.properties template.
#   Default: 9001
#
# [*config*]
#   Puppet uri (as in the source attribute of the file resource) of a custom sonar.properties file.
#   Default: undef
#
# [*use_package]
#    Boolean.  Wether to install from a package.  Only rpm end deb packages are supported.
#    Default: false
#
# [*package_name*]
#   The name of the package to be isntalled.
#   Default: sonarqube
#
# [*manage_repo*]
#    Boolean.  Wether to install the repo configuration to install usin a package.
#    Requires following module as dependencies:
#    * danin/zypprepo
#    * puppetlabs/apt
#
# [*repo_url*]
#    The url to be used in the repo configuration.
#    Default: see sonarqube::params
#
# Usage
# =====
#
# include ::sonarqube
#
# Authors
# =======
#
# mike@marseglia.org
# Forked from MaestroDev
#
# License
# =======
#
# Copyright 2011 MaestroDev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
class sonarqube (
  $version          = '5.6.3',
  $user             = 'sonar',
  $group            = 'sonar',
  $user_system      = true,
  $service          = $sonarqube::params::service,
  $installroot      = '/usr/local',
  $packageroot      = '/opt',
  $home             = "${sonarqube::params::home_base}/${sonarqube::params::service}",
  $host             = undef,
  $port             = 9000,
  $portAjp          = -1,
  $download_url     = 'https://sonarsource.bintray.com/Distribution/sonarqube',
  $download_dir     = '/tmp',
  $context_path     = '/',
  $arch             = $sonarqube::params::arch,
  $https            = {},
  $ldap             = {},
  # ldap and pam are mutually exclusive. Setting $ldap will annihilate the setting of $pam
  $pam              = {},
  $crowd            = {},
  $jdbc             = {
    url                               => 'jdbc:h2:tcp://localhost:9092/sonar',
    username                          => 'sonar',
    password                          => 'sonar',
    max_active                        => '50',
    max_idle                          => '5',
    min_idle                          => '2',
    max_wait                          => '5000',
    min_evictable_idle_time_millis    => '600000',
    time_between_eviction_runs_millis => '30000',
  },
  $log_folder       = "${sonarqube::params::home_base}/${sonarqube::params::service}/logs",
  $updatecenter     = true,
  $http_proxy       = {},
  $https_proxy      = {},
  $profile          = false,
  $web_java_opts    = undef,
  $search_java_opts = undef,
  $search_host      = '127.0.0.1',
  $search_port      = '9001',
  $config           = undef,
  $use_package      = false,
  $package_name     = 'sonarqube',
  $manage_repo      = false,
  $repo_url         = $sonarqube::params::repo_url,
) inherits sonarqube::params {

  # proxy setting validation
  # must define host and port 
  if !empty($http_proxy) {
    if has_key($http_proxy, 'port') and has_key($http_proxy, 'host') {
      if $http_proxy['port'] == '' or $http_proxy['host'] == '' {
        fail('When defining http_proxy hash, both host and port are mandatory')
      }
    } else {
      fail('When defining http_proxy hash, both host and port are mandatory')
    }
  }

  if !empty($https_proxy) {
    if has_key($https_proxy, 'port') and has_key($https_proxy, 'host') {
      if $https_proxy['port'] == '' or $https_proxy['host'] == '' {
        fail('When defining http_proxy hash, both host and port are mandatory')
      }
    } else {
      fail('When defining http_proxy hash, both host and port are mandatory')
    }
  }

  # http_proxy and https_proxy port cannot be the same
  if has_key($http_proxy, 'port') and has_key($https_proxy, 'port') {
    if $http_proxy['port'] == $https_proxy['port'] {
      fail('When both defining http_proxy and https_proxy hashes, you cannot use the same port number !')
    }
  }
  # end proxy vaildation

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }

  File {
    owner => $user,
    group => $group,
  }

  if $use_package {
    validate_absolute_path($packageroot)
    $installdir = "${packageroot}/${service}"
    $extensions_dir = "${installdir}/extensions"
  } else {
    validate_absolute_path($installroot)
    $installdir = "${installroot}/${service}"
    $extensions_dir = "${home}/extensions"
  }
  $plugin_dir = "${extensions_dir}/plugins"


  $tmpzip = "${download_dir}/${package_name}-${version}.zip"

  # /usr/local/sonar/bin/linux-x86-64/
  $script = "${installdir}/bin/${arch}/sonar.sh"

  # create user, group to run sonarqube
  user { $user:
    ensure     => present,
    home       => $home,
    managehome => false,
    system     => $user_system,
  }

  group { $group:
    ensure => present,
    system => $user_system,
  }

  # ensure data directory exists
  # moved outside the install dir
  # also needed for the package, since used for PID file
  file { $home:
    ensure => directory,
    mode   => '0700',
  }

  if $use_package {
    # package based installation
    if $manage_repo {
      class { '::sonarqube::repo':
        repo_url => $repo_url,
        before   => Package[$package_name],
      }
    } # only redhats for the moment - should go to its own class with the logic

    package { $package_name:
      ensure => $version,
    }

  } else {

    #archive based installation
    ensure_packages(['unzip'], { 'ensure' => 'present' })

    Sonarqube::Move_to_home{
      home => $home,
    }

    sonarqube::move_to_home { [ 'data', 'extras', 'extensions', 'logs' ] : }

    # download the sonarqube binary and unpack in the install directory
    archive { $tmpzip:
      ensure       => present,
      extract      => true,
      extract_path => $installroot,
      source       => "${download_url}/${package_name}-${version}.zip",
      user         => $user,
      group        => $group,
      creates      => "/usr/local/${package_name}-${version}/COPYING",
      notify       => Service['sonarqube'],
      require      => [ File["${installroot}/${package_name}-${version}"], Package['unzip'],
                        Sonarqube::Move_to_home['data', 'extras', 'extensions', 'logs'] ],
    }

    # ensure install directory exists
    # also create data directories and symlink them before extracting archive
    # otherwise symlink will fail b/c target will already exist
    file { "${installroot}/${package_name}-${version}":
      ensure => directory,
    }

    file { $installdir:
      ensure  => link,
      target  => "${installroot}/${package_name}-${version}",
      notify  => Service['sonarqube'],
      require => File["${installroot}/${package_name}-${version}"],
    }

    file { $plugin_dir:
      ensure  => directory,
      require => Sonarqube::Move_to_home['extensions'],
    }
  }   # end installation

  # Sonar configuration files

  $real_require = $use_package ? {
    true  => "Package[${package_name}]",
    false => "Archive[${tmpzip}]",
  }

  if $config != undef {
    file { "${installdir}/conf/sonar.properties":
      source  => $config,
      notify  => Service['sonarqube'],
      mode    => '0600',
      require => $real_require,
    }
  } else {
    file { "${installdir}/conf/sonar.properties":
      ensure  => file,
      content => template('sonarqube/sonar.properties.erb'),
      notify  => Service['sonarqube'],
      mode    => '0600',
      require => $real_require,
    }
  }

  file { $script:
    ensure  => file,
    mode    => '0755',
    content => template('sonarqube/sonar.sh.erb'),
    require => $real_require,
  }

  file { "/etc/init.d/${service}":
    ensure  => link,
    target  => $script,
    require => $real_require,
  }

  if $::systemd {
    systemd::unit_file{"${service}.service":
      path    => '/usr/lib/systemd/system/',
      content => template("${module_name}/sonarqube.systemd.erb"),
      before  => Service['sonarqube'],
    }
  }

  $_service_require = $use_package ? {
    true  => [ Package[$package_name], File["/etc/init.d/${service}"] ],
    false => [ Archive[$tmpzip], File["/etc/init.d/${service}"] ],
  }

  service { 'sonarqube':
    ensure     => running,
    name       => $service,
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => $_service_require,
  }
}

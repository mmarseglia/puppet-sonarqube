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
  String $version          = '5.6.3',
  String $user             = 'sonar',
  String $group            = 'sonar',
  Bool $user_system      = true,
  $service          = $sonarqube::params::service,
  String $installroot      = '/usr/local',
  String $packageroot      = '/opt',
  String $home             = "${sonarqube::params::home_base}/${sonarqube::params::service}",
  $host             = undef,
  $port             = 9000,
  $portAjp          = -1,
  String $download_url     = 'https://sonarsource.bintray.com/Distribution/sonarqube',
  String $download_dir     = '/tmp',
  String $context_path     = '/',
  $arch             = $sonarqube::params::arch,
  Hash $https            = {},
  Hash $ldap             = {},
  # ldap and pam are mutually exclusive. Setting $ldap will annihilate the setting of $pam
  Hash $pam              = {},
  Hash $crowd            = {},
  Hash $jdbc             = {
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
  String $log_folder       = "${sonarqube::params::home_base}/${sonarqube::params::service}/logs",
  Bool $updatecenter     = true,
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

  #archive based installation
  ensure_packages(['unzip'], { 'ensure' => 'present' })

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }

  File {
    owner => $user,
    group => $group,
  }

  class { '::sonarqube::account' }->
  class { '::sonarqube::package' }->
  class { '::sonarqube::config' }->
  class { '::sonarqube::service' }
}

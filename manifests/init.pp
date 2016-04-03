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
  $version          = '5.3',
  $user             = 'sonar',
  $group            = 'sonar',
  $user_system      = true,
  $service          = 'sonar',
  $installroot      = '/usr/local',
  $home             = undef,
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
  $log_folder       = '/var/local/sonar/logs',
  $updatecenter     = true,
  $http_proxy       = {},
  $profile          = false,
  $web_java_opts    = undef,
  $search_java_opts = undef,
  $search_host      = '127.0.0.1',
  $search_port      = '9001',
  $config           = undef,
) inherits sonarqube::params {
  validate_absolute_path($download_dir)

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }

  File {
    owner => $user,
    group => $group,
  }

  ensure_packages(['unzip'], { 'ensure' => 'present' })

  $package_name = 'sonarqube'

  if $home != undef {
    $real_home = $home
  } else {
    $real_home = '/var/local/sonar'
  }

  Sonarqube::Move_to_home {
    home => $real_home,
  }

  $extensions_dir = "${real_home}/extensions"

  $plugin_dir = "${extensions_dir}/plugins"

  $installdir = "${installroot}/${service}"

  $tmpzip = "${download_dir}/${package_name}-${version}.zip"

  # /usr/local/sonar/bin/linux-x86-64/
  $script = "${installdir}/bin/${arch}/sonar.sh"

  # create user, group to run sonarqube
  user { $user:
    ensure     => present,
    home       => $real_home,
    managehome => false,
    system     => $user_system,
  }

  group { $group:
    ensure => present,
    system => $user_system,
  }

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
    require      => [ File["${installroot}/${package_name}-${version}"], Package['unzip'] ],
  }

  # Sonar home
  file { $real_home:
    ensure => directory,
    mode   => '0700',
  }

  file { "${installroot}/${package_name}-${version}":
    ensure => directory,
  }

  file { $installdir:
    ensure  => link,
    target  => "${installroot}/${package_name}-${version}",
    notify  => Service['sonarqube'],
    require => File["${installroot}/${package_name}-${version}"],
  }

  #sonarqube::move_to_home { 'data': }
  #sonarqube::move_to_home { 'extras': }
  #sonarqube::move_to_home { 'extensions': }
  #sonarqube::move_to_home { 'logs': }

  file { $script:
    mode    => '0755',
    content => template('sonarqube/sonar.sh.erb'),
    require => File[$installdir],
  }

  file { "/etc/init.d/${service}":
    ensure  => link,
    target  => $script,
    require => File[$script],
  }

  # Sonar configuration files
  if $config != undef {
    file { "${installdir}/conf/sonar.properties":
      source => $config,
      notify => Service['sonarqube'],
      mode   => '0600',
    }
  } else {
    file { "${installdir}/conf/sonar.properties":
      content => template('sonarqube/sonar.properties.erb'),
      notify  => Service['sonarqube'],
      mode    => '0600',
    }
  }

  # The plugins directory.
  #file { $plugin_dir:
  #  ensure => directory,
  #}

  service { 'sonarqube':
    ensure     => running,
    name       => $service,
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => File["/etc/init.d/${service}"],
  }
}

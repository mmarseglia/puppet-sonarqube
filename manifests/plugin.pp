# Definition: plugin
#
# A puppet definition installing/removing a Sonar plugin installation
#
# Attributes
# ==========
#
# [*version*] (mandatory)
#   The version of the plugin to be installed.  When isntalling from package
#   keep the version format in mind. (eg. 1.3-1)
#
# [*ensure*]
#   Either to install (present), or remove (absent) the plugin.  This will trigger a restart
#   of the sonarqube service.
#   Default: present
#
# [*artifactid*]
#   The artifactis to download from the mavem repository, or the packagename when installing
#   from package.
#   Default: $title
#
# [*groupid*]
#   The groupid from the maven repository
#   Default: org.codehaus.sonar-plugins
#
# [*use_package*]
#   Install from a package (true) or from a maven repository.
#   Default: false
#
# Examples
# ========
#
#  sonarqube::plugin{ 'sonar-puppet-plugin':
#    version     => '1.3-1',
#    use_package => true,
#  }
#
#  sonarqube::plugin{ 'sonar-puppet-plugin':
#    version => '1.3',
#  }
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
#
define sonarqube::plugin(
  $version,
  $ensure      = present,
  $artifactid  = $title,
  $groupid     = 'org.codehaus.sonar-plugins',
  $use_package = false,
) {
  $plugin_name = "${artifactid}-${version}.jar"
  $plugin      = "${sonarqube::plugin_dir}/${plugin_name}"

  if !($ensure in [ 'present', 'absent'] ) {
    fail("Resource sonarqube::plugin: Attribute ensure can only be present or absent, got ${ensure}")
  }

  if $use_package {
    if $ensure == present {
      package{ $artifactid:
        ensure => $version,
        notify => Service['sonarqube'],
      }
    } else {
      package{ $artifactid:
        ensure => $ensure,
        notify => Service['sonarqube'],
      }
    }
  } else {
    # Install plugin
    if $ensure == present {
      # copy to a temp file as Maven can run as a different user and not have rights to copy to
      # sonar plugin folder
      maven { "/tmp/${plugin_name}":
        groupid    => $groupid,
        artifactid => $artifactid,
        version    => $version,
        before     => File[$plugin],
        require    => File[$sonarqube::plugin_dir],
      }
      ~>
      exec { "remove-old-versions-of-${artifactid}":
        command     => "/tmp/cleanup-old-plugin-versions.sh ${sonarqube::plugin_dir} ${artifactid} ${version}",
        path        => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
        refreshonly => true,
      }
      ->
      file { $plugin:
        ensure => $ensure,
        source => "/tmp/${plugin_name}",
        owner  => $sonarqube::user,
        group  => $sonarqube::group,
        notify => Service['sonarqube'],
      }
    } else {
      # Uninstall plugin if absent
      file { $plugin:
        ensure => $ensure,
        notify => Service['sonarqube'],
      }
    }
  }
}

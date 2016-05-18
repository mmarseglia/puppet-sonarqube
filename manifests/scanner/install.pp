# Installation of SonarQube scanner
# 
# This is a private class.  
# see sonarqube::scanner class for parameter explenation
#
class sonarqube::scanner::install (
  $package_name   = 'sonar-scanner',
  $version        = '2.6',
  $download_url   = 'https://sonarsource.bintray.com/Distribution/sonar-scanner-cli',
  $installroot    = '/usr/local/',
  $use_package    = false,
  $manage_profile = true,
  $manage_link    = true,
  $tmp_dir        = '/tmp',
) {

  # Validation is handled by the calling class sonarqube::scanner

  if $use_package {
    package { $package_name:
      ensure => $version,
    }
  } else {
    include ::archive

    ensure_packages(['unzip'], { 'ensure' => 'present' })

    archive { "${tmp_dir}/${package_name}-${version}.zip" :
      ensure       => present,
      source       => "${download_url}/${package_name}-${version}.zip",
      extract      => true,
      extract_path => $installroot,
      creates      => "${installroot}${package_name}-${version}",
      require      => Package['unzip'],
    }
  }

  ## generate ths correct values depending on the settings
  if $use_package {
    $_basedir    = dirname($installroot)
    $link_name   = "${_basedir}/sonar-scanner"
    $target_name = $installroot
  } else {
    $link_name   = "${installroot}/sonar-scanner"
    $target_name = "${installroot}${package_name}-${version}"
  }

  if $manage_link {
    file { $link_name :
      ensure => 'link',
      target => $target_name,
    }
  }

  if $manage_profile {
    # Sonar settings for terminal sessions.
    $_content = $manage_link ? {
      true  => "export SONAR_SCANNER_HOME=${link_name}",
      false => "export SONAR_SCANNER_HOME=${target_name}",
    }
    file { '/etc/profile.d/sonarhome.sh':
      content => $_content,
    }
  }
}

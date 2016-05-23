# Configuration of SonarQube scanner
#
# This is a private class.  
# see sonarqube::scanner class for parameter explenation
#
class sonarqube::scanner::config (
  $package_name = 'sonar-scanner',
  $version = '2.6',
  $installroot = '/usr/local',
  $sonarqube_server = 'http://localhost:9000',
  $use_package = false,
  $jdbc = {},
) {

  if $use_package {
    $_installdir = $installroot
  } else {
    $_installdir = "${installroot}/${package_name}-${version}"
  }

  # Sonar Runner configuration file
  file { "${_installdir}/conf/sonar-scanner.properties":
    ensure  => file,
    content => template('sonarqube/sonar-scanner.properties.erb'),
    require => Class['sonarqube::scanner::install'],
  }
}

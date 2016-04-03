# Configuration of SonarQube scanner
class sonarqube::scanner::config (
  $package_name = 'sonar-scanner',
  $version = '2.5',
  $installroot = '/usr/local/',
  $sonarqube_server = 'http://localhost:9000',
  $tmp_dir  = '/tmp',

  # JDBC not used used for SonarQube 5.2+
  $jdbc             = { },

) {
  # Sonar Runner configuration file
  file { "${installroot}/${package_name}-${version}/conf/sonar-runner.properties":
    content => template('sonarqube/sonar-runner.properties.erb'),
    require => Archive["${tmp_dir}/${package_name}-${version}.zip"],
  }
}

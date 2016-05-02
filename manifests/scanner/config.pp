# Configuration of SonarQube scanner
class sonarqube::scanner::config (
  $package_name = 'sonar-scanner',
  $version = '2.6',
  $installroot = '/usr/local/',
  $sonarqube_server = 'http://localhost:9000',
  $tmp_dir  = '/tmp',
  $jdbc = { },

) {
  # Sonar Runner configuration file
  file { "${installroot}/${package_name}-${version}/conf/sonar-runner.properties":
    content => template('sonarqube/sonar-runner.properties.erb'),
    require => Archive["${tmp_dir}/${package_name}-${version}.zip"],
  }
}

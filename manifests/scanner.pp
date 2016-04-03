# Class: sonarqube::runner
#
# Install the sonar-runner
class sonarqube::scanner (
    $package_name = 'sonar-scanner',
    $version = '2.5',
    $download_url = 'https://sonarsource.bintray.com/Distribution/sonar-scanner-cli',
    $installroot = '/usr/local/',
    $sonarqube_server = 'http://localhost:9000',
) {

  validate_string($package_name)
  validate_absolute_path($installroot)

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }

  anchor { 'sonarqube::scanner::begin': } ->
  class { '::sonarqube::scanner::install':
    package_name => $package_name,
    version      => $version,
    download_url => $download_url,
    installroot  => $installroot,
  } ->
  class { '::sonarqube::scanner::config':
    package_name     => $package_name,
    version          => $version,
    installroot      => $installroot,
    sonarqube_server => $sonarqube_server,
  } ~>
  anchor { 'sonarqube::scanner::end': }
}

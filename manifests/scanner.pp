# Class: sonarqube::scanner
#
# Description
# Install the sonar-scanner.
#
class sonarqube::scanner (
    $package_name = 'sonar-scanner',
    $version = '2.6',
    $download_url = 'https://sonarsource.bintray.com/Distribution/sonar-scanner-cli',
    $installroot = '/usr/local/',
    $packageroot = '/opt',
    $sonarqube_server = 'http://localhost:9000',
    $use_package = false
) {

  validate_string($package_name)
  validate_absolute_path($installroot)
  validate_absolute_path($packageroot)
  validate_bool($use_package)

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }

  if $use_package {
    $real_root = $packageroot
  } else {
    $real_root = $installroot
  }

  anchor { 'sonarqube::scanner::begin': } ->
  class { '::sonarqube::scanner::install':
    package_name => $package_name,
    version      => $version,
    download_url => $download_url,
    installroot  => $installroot,
    use_package  => $use_package,
  } ->
  class { '::sonarqube::scanner::config':
    package_name     => $package_name,
    version          => $version,
    installroot      => $real_root,
    sonarqube_server => $sonarqube_server,
  } ~>
  anchor { 'sonarqube::scanner::end': }
}

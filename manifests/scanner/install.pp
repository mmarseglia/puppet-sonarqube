# Installation of SonarQube scanner
class sonarqube::scanner::install (
  $package_name = 'sonar-scanner',
  $version = '2.6',
  $installroot = '/usr/local/',
  $download_url = 'https://sonarsource.bintray.com/Distribution/sonar-scanner-cli',
  $tmp_dir = '/tmp',
) {
  include ::archive


  archive { "${tmp_dir}/${package_name}-${version}.zip" :
    ensure       => present,
    source       => "${download_url}/${package_name}-${version}.zip",
    extract      => true,
    extract_path => $installroot,
    creates      => "${installroot}${package_name}-${version}",
  }
  
  file { '/usr/local/sonar-runner':
      ensure => 'link',
      target => "${installroot}${package_name}-${version}",
  }

  # Sonar settings for terminal sessions.
  file { '/etc/profile.d/sonarhome.sh':
    content => 'export SONAR_RUNNER_HOME=/usr/local/sonar-runner',
  }
}

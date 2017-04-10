class sonarqube::service {

  class { '::sonarqube::service::install'
  }->
  service { 'sonarqube':
    ensure     => running,
    name       => 'sonarqube',
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
  }
}
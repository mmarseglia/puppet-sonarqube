class sonarqube::config (
	String $install_directory 	= $::sonarqube::params::install_directory,
	String $config 				= $::sonarqube::params::config,
	String $user				= $::sonarqube::params::user,
	String $group 				= $::sonarqube::params::group,
	) inherits sonarqube::params {

File {
	user 	=> $user,
	group 	=> $group,
	mode	=> '0600',
}

# Sonar configuration files
  if $config {
    file { "${installdir}/conf/sonar.properties":
      source  => $config,
      notify  => Service['sonarqube'],
  }
  }
 else {
   	file { "${installdir}/conf/sonar.properties":
      ensure  => file,
      content => template('sonarqube/sonar.properties.erb'),
      notify  => Service['sonarqube'],
  	}
 }
  }

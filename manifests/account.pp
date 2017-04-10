class sonarqube::account (
	String $user = 'sonarqube',
	String $group = 'sonarqube',
	Bool $user_system = true
) {
  # create user, group to run sonarqube
  user { $user:
    ensure     => present,
    home       => $home,
    managehome => false,
    system     => $user_system,
  }

  group { $group:
    ensure => present,
    system => $user_system,
  }
}
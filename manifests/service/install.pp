class sonarqube::service::install (
  String $init_script = "/usr/local/sonarqube/bin/x86_64/sonar.sh",
) {

  File {
    owner => 'root',
    user  => 'root',
    mode  => '0744',
  }

  if $::systemd {
    systemd::unit_file { "sonarqube.service" :
      path    => '/usr/lib/systemd/system/',
      content => template("sonarqube/sonarqube.systemd.erb"),
    }
  } else {
    file { $script:
      ensure  => file,
      content => template('sonarqube/sonar.sh.erb'),
    }->

    file { "/etc/init.d/sonarqube":
      ensure  => link,
      target  => $script,
    }
  }
}
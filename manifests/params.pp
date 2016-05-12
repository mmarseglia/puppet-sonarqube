# Class: sonarqube::params
class sonarqube::params {

  # calculate in what folder is the binary to use for this architecture
  $arch1 = $::kernel ? {
    'windows' => 'windows',
    'sunos'   => 'solaris',
    'darwin'  => 'macosx',
    default   => 'linux',
  }

  if $arch1 != 'macosx' {
    $arch2 = $::architecture ? {
      'x86_64' => 'x86-64',
      'amd64'  => 'x86-64',
      default  => 'x86-32',
    }
  } else {
    $arch2 = $::architecture ? {
      'x86_64' => 'universal-64',
      default  => 'universal-32',
    }
  }

  $arch = "${arch1}-${arch2}"

  case $::osfamily {
    'RedHat','Suse': {
      $repo_url = 'http://downloads.sourceforge.net/project/sonar-pkg/rpm'
    }
    'Debian': {
      $repo_url = 'http://downloads.sourceforge.net/project/sonar-pkg/deb'
    }
    default: {
      fail('Only repos for Redhat, Debian en Suse are available')
    }
  }
}

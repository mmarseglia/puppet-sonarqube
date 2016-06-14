# class sonarqube::repo
#
# [*repo_url*]
# uri where the repo can be found
#

class sonarqube::repo (
  $repo_url = $sonarqube::params::repo_url,
) inherits ::sonarqube::params
{
  case $::osfamily {
    'redhat': {
      yumrepo { 'sonarqube':
        ensure   => 'present',
        enabled  => 1,
        baseurl  => $repo_url,
        descr    => 'Sonar Native Packages Repo',
        gpgcheck => '0',
      }
    }
    'Debian': {
      # needs the puppetlabs/opt module
      apt::source { 'sonarqube':
        location => $repo_url,
        repos    => 'Sonarque debian package repo',
        release  => 'binary',
      }
    }
    'Suse': {
      # needs the danin/zypprepo 
      zypprepo { 'sonarqube':
        enabled      => 1,
        baseurl      => $repo_url,
        autorefresh  => 1,
        name         => 'sonarqube',
        gpgcheck     => 0,
        priority     => 98,
        keeppackages => 1,
        type         => 'rpm-md',
      }
    }
    default: {
      fail("Unsupported OS ${::osfamily}. Only RedHat, Debian and Suse are supported.")
    }
  }
}

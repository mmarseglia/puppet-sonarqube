# Class: sonarqube::scanner
#
# Description
# Installs and configures the sonar-scanner.
#
# Parameters
# ----------
#
# [*package_name*]
# The name of the archive (without version) or the package to be retrfevied/installed
# Defualt: 'sonar-scanner'
#
# [*version*] 
# The version to be retrieved/isntalle. Be aware of the version when using a package (eg 2.6-1)
# Default: '2.6'
#
# [*download_url*]
# The url to retrieve the package from.  Only used when $use_package = false
# Default: 'https://sonarsource.bintray.com/Distribution/sonar-scanner-cli'
#
# [*installroot*]
# When $use_package=false:
# The basedir where the retrieved archive will be installed.
# When $use_packag=true
# The full path where the sonar-scanner software can be found.  This must be set
# when installing from package. (eg. /opt/sonar-sanner-2.6). 
# Default: '/usr/local'
# 
# [*sonarqube_server*]
# The uri of the sonarqube server
# Default: 'http://localhost:9000'
#
# [*use_package*]
# Boolean.  Wether to install form the archive (false) or
# to install from a package (true)
# Default: false
#
# [*manage_profile*] 
# Boolean.  When set to true, puppet will manage the /etc/profile.d/sonarhome.sh.
# When set to false this wil be skipped. This gives you the freedom to manage this file
# with eg a postinstall scrip included in the package.
# Default: true
#
# [*manage_link*]
# Boolean. 
# When $use_package=false:
# Creates a symbolic link from ${installroot}/${package_name}-${version} -> ${installroot}/sonar-scanner
# When $use_package=true:
# It will create a symbolic link from $installroot to dirname($installroot)/sonar-scanner
# When true, this will influence the content of the /etc/profile.d/sonarhome.sh.  When true, the symbolic link will
# be used, otherwise the real path will be used.
# Default: true
#
# [*jdbc*]
# When using sonarqube <= 5.1, the jdbc settings as used in the sonarqube server should be passed
# to the the sonar-scanner.  This module does not validate this condition.
# It is just passed ans used in the sonar.scanner.properties template when provided.
# Default: {}
#
# Note about use_package
# ----------------------
# Sonce no package of the sonar-scanner is available, it is your responsibility to
# create and provide such package.
# The  recommended tool for creating the package is 'fpm'. Following example wil create a
# rpm from the sonar-scanner zip file.
#
# ````
#  fpm -s zip \
#      -t rpm \
#      --prefix /opt \
#      -n sonar-scanner_vdab \
#      --provides sonar-scanner \
#      --provides sonar-runner \
#      -v 2.6 \
#      -m support@somedomain.com \ 
#      -a noarch \
#      --after-install post_install.sh \
#      --after-remove post_rm.sh \
#      sonar-scanner-2.6.zip
# ````
#
# In this example,  post_install.sh is used to create the /etc/profile.d/sonarhome.sh (or simular).
# The post_rm.sh cleans up after removing the package.
# 
# Remember to set the manage_profile and manage_link depending on the post install actions provided by the package.
#
# Usage
# -----
# 
# include sonarqube::scanner
#
# class { 'sonarqube::scanner':
#   package_name   => 'sonar-scanner_companyX',
#   version        => '2.6-2',
#   installroot    => '/opt/sonar-scanner-2.6',
#   use_package    => true,
#   manage_profile => false,
# }
#
class sonarqube::scanner (
    $package_name     = 'sonar-scanner',
    $version          = '2.6',
    $download_url     = 'https://sonarsource.bintray.com/Distribution/sonar-scanner-cli',
    $installroot      = '/usr/local/',
    $sonarqube_server = 'http://localhost:9000',
    $use_package      = false,
    $manage_profile   = true,
    $manage_link      = true,
    $jdbc             = {},
) {

  validate_string($package_name)
  validate_absolute_path($installroot)
  validate_bool($use_package)
  validate_bool($manage_profile)
  validate_bool($manage_link)

  anchor { 'sonarqube::scanner::begin': } ->
  class { '::sonarqube::scanner::install':
    package_name   => $package_name,
    version        => $version,
    download_url   => $download_url,
    installroot    => $installroot,
    use_package    => $use_package,
    manage_profile => $manage_profile,
    manage_link    => $manage_link,
  } ->
  class { '::sonarqube::scanner::config':
    package_name     => $package_name,
    version          => $version,
    installroot      => $installroot,
    sonarqube_server => $sonarqube_server,
    use_package      => $use_package,
    jdbc             => $jdbc,
  } ~>
  anchor { 'sonarqube::scanner::end': }
}

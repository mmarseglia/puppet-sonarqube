class sonarqube::package {

	File {
		user => $::sonarqube::user,
		group => $::sonarqube::group,
	}

	  $tmpzip = "${download_dir}/${package_name}-${version}.zip"
  $plugin_dir = "${extensions_dir}/plugins"

  # ensure data directory exists
  # moved outside the install dir
  # also needed for the package, since used for PID file
  file { $home:
    ensure => directory,
    mode   => '0700',
  }

  if $use_package {
    validate_absolute_path($packageroot)
    $installdir = "${packageroot}/${service}"
    $extensions_dir = "${installdir}/extensions"
  } else {
    validate_absolute_path($installroot)
    $installdir = "${installroot}/${service}"
    $extensions_dir = "${home}/extensions"
  }

  if $use_package {
    # package based installation
    if $manage_repo {
      class { '::sonarqube::repo':
        repo_url => $repo_url,
        before   => Package[$package_name],
      }
    } # only redhats for the moment - should go to its own class with the logic

    package { $package_name:
      ensure => $version,
    }

  } else {

    Sonarqube::Move_to_home{
      home => $home,
    }

    sonarqube::move_to_home { [ 'data', 'extras', 'extensions', 'logs' ] : }

    # download the sonarqube binary and unpack in the install directory
    archive { $tmpzip:
      ensure       => present,
      extract      => true,
      extract_path => $installroot,
      source       => "${download_url}/${package_name}-${version}.zip",
      user         => $user,
      group        => $group,
      creates      => "/usr/local/${package_name}-${version}/COPYING",
      notify       => Service['sonarqube'],
      require      => [ File["${installroot}/${package_name}-${version}"], Package['unzip'],
                        Sonarqube::Move_to_home['data', 'extras', 'extensions', 'logs'] ],
    }

    # ensure install directory exists
    # also create data directories and symlink them before extracting archive
    # otherwise symlink will fail b/c target will already exist
    file { "${installroot}/${package_name}-${version}":
      ensure => directory,
    }->

    file { $installdir:
      ensure  => link,
      target  => "${installroot}/${package_name}-${version}",
      notify  => Service['sonarqube'],
    }

    file { $plugin_dir:
      ensure  => directory,
      require => Sonarqube::Move_to_home['extensions'],
    }
  }   # end installation

}
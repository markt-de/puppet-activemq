# @summary Install ActiveMQ distribution archive
#
# All installation files and directories are created as root. Only
# per-instance files and directories need to be writable by the ActiveMQ
# user.
#
# @api private
class activemq::install {
  # Add the filename to the correct position.
  $filename = "${activemq::distribution_name}-${activemq::version}-bin.tar.gz"
  $source_url = sprintf($activemq::download_url, $filename)

  $archive_file = "${activemq::install_base}/${filename}"
  $install_dir = "${activemq::install_base}/${activemq::distribution_name}-${activemq::version}"
  $symlink_full = "${activemq::install_base}/${activemq::symlink_name}"

  # Download and extract the distribution archive.
  archive { $archive_file:
    ensure        => present,
    user          => 'root',
    group         => 'root',
    source        => $source_url,
    checksum      => $activemq::checksum,
    checksum_type => $activemq::checksum_type,
    extract_path  => $activemq::install_base,
    # Extract files as the user doing the extracting, which is the user
    # that runs Puppet, usually root
    extract_flags => '-x --no-same-owner -f',
    creates       => $install_dir,
    extract       => true,
    cleanup       => true,
    proxy_server  => $activemq::proxy_server,
    proxy_type    => $activemq::proxy_type,
  }

  # Set symlink to current version.
  file { $symlink_full:
    ensure  => link,
    require => Archive[$archive_file],
    target  => $install_dir,
  }

  # Create user and group (only required for instances).
  if $activemq::manage_account {
    group { $activemq::group:
      ensure => present,
      gid    => $activemq::gid,
    }
    -> user { $activemq::user:
      ensure     => present,
      uid        => $activemq::uid,
      gid        => $activemq::group,
      home       => $activemq::instances_base,
      managehome => false,
    }
  }

  # Create base directory.
  if $activemq::manage_instances_base {
    file { $activemq::instances_base:
      ensure => directory,
      owner  => $activemq::user,
      group  => $activemq::group,
      mode   => '0755',
    }
  }
}

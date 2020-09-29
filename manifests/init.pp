# @summary Install and configure ActiveMQ Artemis
#
# @param admin_password
#   Specifies the password to use for standalone instances.
#
# @param admin_user
#   Specifies the name of the user to use for standalone instances.
#
# @param checksum
#   Specifies the checksum for the distribution archive, which will be verified
#   after downloading the file and before starting the installation.
#
# @param checksum_type
#   Specifies the type of the checksum. Defaults to `sha512`.
#
# @param cluster
#   Whether to setup a cluster or a standalone instance.
#
# @param cluster_name
#   Specifies the name to use for the cluster.
#
# @param cluster_password
#   Specifies the password to use for clustered instances.
#
# @param cluster_user
#   Specifies the name of the user to use for clustered instances.
#
# @param cluster_topology
#   The topology of the cluster, which should contain ALL instances across the
#   whole cluster (not only local instances), their settings and relationships.
#
# @param distribution_name
#   Specifies the name of the distribution, which is usually used to build
#   the actual download URL.
#
# @param download_url
#   Specifies the download location. It should contain a `%s` string which
#   is automatically replaced with the actual filename during installation.
#   The latter makes it easier to use mirror redirection URLs.
#
# @param gid
#   Specifies an optional GID that should be used when creating the group.
#
# @param group
#   Specifies the name of the group to use for the service/instance.
#
# @param install_base
#   Specifies the installation directory. This directory must already exist.
#   A subdirectory for every version is automatically created.
#
# @param instance_defaults
#   The default parameters for all instances. They are merged with all
#   instance-specific parameters. This makes it obsolete to specify ALL
#   required parameters for every instance, but only parameters that differ
#   from these defaults.
# 
# @param instances
#  A list of instances that should be created.
#
# @param instances_base
#   Specifies the directory where broker instances should be installed.
#   This directory must already exist. A subdirectory for every instance is
#   automatically created.
#
# @param manage_account
#   Whether or not to create the user and group.
#
# @param manage_instances_base
#   Whether or not to create the directory specified in `$instances_base`.
#
# @param port
#   Specifies the port to use for the artemis connector and will also be used
#   as default port for the acceptor.
#
# @param server_discovery
#   Controls how servers can propagate their connection details.
#
# @param service_enable
#   Specifies whether the service should be enabled.
#
# @param service_ensure
#   Specifies the desired state for the service.
#
# @param service_file
#   Specifies the filename of the service file.
#
# @param service_name
#   Controls the name of the system service. Must NOT be changed while
#   instances are running.
#
# @param symlink_name
#   Controls the name of a version-independent symlink. It will always point
#   to the release specified by `$version`.
#
# @param uid
#   Specifies an optional UID that should be used when creating the user.
#
# @param user
#   Specifies the name of the user to use for the service/instance.
#
# @param version
#   Specifies the version of ActiveMQ (Artemis) to install and use. No default
#   value is provided on purpose, to avoid prevent new users from using a
#   outdated version and to avoid unexpected updates by later changing the
#   default value.
#
class activemq (
  String $admin_password,
  String $admin_user,
  String $bootstrap_template,
  String $broker_template,
  Boolean $cluster,
  String $cluster_password,
  String $cluster_user,
  Hash[String[1], Hash] $cluster_topology,
  String $distribution_name,
  String $download_url,
  String $group,
  Stdlib::Compat::Absolute_path $install_base,
  Hash $instance_defaults,
  Hash[String[1], Hash] $instances,
  Stdlib::Compat::Absolute_path $instances_base,
  String $logging_template,
  Boolean $manage_account,
  Boolean $manage_instances_base,
  Integer $port,
  Enum['dynamic','static'] $server_discovery,
  Boolean $service_enable,
  Enum['running','stopped'] $service_ensure,
  Stdlib::Compat::Absolute_path $service_file,
  String $service_name,
  String $service_template,
  String $symlink_name,
  String $user,
  String $version,
  Optional[String] $checksum = undef,
  Optional[String] $checksum_type = undef,
  Optional[String] $cluster_name = undef,
  Optional[Integer] $gid = undef,
  Optional[Integer] $uid = undef,
) {
  # Perform basic installation steps
  class { 'activemq::install': }
  ~> class { 'activemq::service': }

  # Ensure that a valid cluster configuration is provided.
  if ($cluster and empty($cluster_name) or !($cluster_name =~ String)) {
    fail('Cluster support is enabled but no value for $cluster_name was provided.')
  } elsif ($cluster and empty($cluster_topology)) {
    fail('Cluster support is enabled but no value for $cluster_topology was provided.')
  }

  # Ensure that the cluster topology is valid.
  if $cluster and !empty($cluster_topology) {
    # Collect connectors for ALL cluster nodes. This is only required when
    # using static connectors, but we will use this opportunity to validate
    # the cluster topology (to some degree).
    $_static_connectors = $cluster_topology.reduce({}) |$memo, $x| {
      # A nested hash contains the instance configuration.
      if ($x[1] =~ Hash) {

        # Fail if no "bind" option was specified.
        if ( !('bind' in $x[1]) ) {
          fail("Invalid \$cluster_topology, no value for \$bind in instance ${x[0]}.")
        }

        # Check if "port" option can be found.
        if ( !('port' in $x[1]) ) {
          # Use default value when not found.
          $_values = $x[1].deep_merge({'port' => $port})
        } else {
          $_values = $x[1]
        }
      } else {
        fail("Invalid \$cluster_topology, expected a Hash but got something else for instance ${x[0]}.")
      }
      # Auto-generated connectors are prefixed with "artemis-".
      $memo + {"artemis-${x[0]}" => $_values}
    }
  } else {
    $_static_connectors = {}
  }

  # Iterate through all instance configurations.
  $instances.each | String $name, Hash $config| {
    # Merge default values with user-specified settings.
    # The latter take precedence.
    $_pre_config = $instance_defaults.deep_merge($config)

    # When using static connectors, merge the previously generated list of
    # static connectors into the instance configuration.
    if ($server_discovery == 'static') {
      $_final_config = $_pre_config.deep_merge('connectors' => $_static_connectors)
    } else {
      # When using dynamic connectors, then only add the connector for this
      # local instance.
      $_final_config = $_pre_config.deep_merge({
        'connectors' => {
          # Auto-generated connectors are prefixed with "artemis-".
          "artemis-${name}" => {
            'bind' => $_pre_config['bind'],
            'port' => $_pre_config['port'],
          }
        }
      })
    }

    # Setup the instance.
    activemq::instance { $name:
      * => $_final_config,
    }
  }
}

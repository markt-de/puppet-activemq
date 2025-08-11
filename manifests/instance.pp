# @summary Create an instance of ActiveMQ Artemis broker
#
# @param acceptors
#   ActiveMQ Artemis acceptors.
#
# @param acceptor_settings
#   Shared settings that should be used for ALL acceptors.
#
# @param address_settings
#   A hash containing global address settings. This is especially useful
#   for wildcard/catch all matches.
#
# @param addresses
#   A hash containing configuration for addresses (messaging endpoints),
#   queues and routing types. Note: Setting adresses and queues to
#   `enable: false` will remove them from the configuration file, but
#   they will still be available in Artemis. In order to completely
#   remove them, the `config-delete-*` options may be set to `FORCE`.
#
# @param allow_failback
#   Should stop backup on live restart.
#
# @param allow_direct_connections_only
#   When using static server discovery only make connections to the
#   defined connectors and not any other broker in the cluser.
#
# @param bind
#   Configure which IP address to listen on. Should be either a FQDN
#   or an IP address.
#
# @param broadcast_groups
#   ActiveMQ Artemis broadcast groups.
#
# @param broker_plugins
#   A hash containing a list of broker plugins and their configuration.
#   Each plugin can be enabled by setting `enable` to `true`.
#
# @param check_for_live_server
#   Used for a live server to verify if there are other nodes with the same ID on the topology.
#
# @param connectors
#   ActiveMQ Artemis connectors.
#
# @param discovery_groups
#   ActiveMQ Artemis discovery groups.
#
# @param failover_on_shutdown
#   This will cause a HA failover to occur on normal server shutdown.
#
# @param global_max_size_mb
#   The amount in Mb before all addresses are considered full.
#
# @param group
#   The group for ActiveMQ Artemis.
#
# @param ha_policy
#   ActiveMQ Artemis HA policy.
#
# @param initial_replication_sync_timeout
#   Timeout for initial replication to complete.
#
# @param java_args
#   Options for the JVM. Be careful to not override required default options.
#   The syntax may look a bit off, but this way it's possible to replace
#   certain values or to remove an option by adding the value 'DISABLED'.
#
# @param java_xms
#   The initial Java heap size.
#
# @param java_xmx
#   The maximum Java heap size.
#
# @param jmx
#   A hash containing settings for the Jolokia JMX console.
#
# @param journal_buffer_timeout
#   The flush timeout for the journal buffer.
#
# @param journal_datasync
#   Whether ActiveMQ Artemis will use msync/fsync on journal operations.
#
# @param journal_max_io
#   The maximum number of write requests that can be in the ASYNCIO queue at any one time.
#
# @param journal_type
#   The type of journal to use.
#
# @param log_level
#   The log levels to use for the various configured loggers (on versions before 2.27.0).
#
# @param log4j_level
#   The log levels to use for the various configured loggers (on version 2.27.0 and later).
#
# @param management_notification_address
#   The address to receive management notifications.
#
# @param max_disk_usage
#   The max percentage of data to use from disks. The broker will block while the disk is full. Disable by setting -1.
#
# @param max_hops
#   Maximum number of hops cluster topology is propagated.
#
# @param message_load_balancing
#   Specifies how messages should be load balanced.
#
# @param persistence
#   Whether the server will use the file based journal for persistence.
#
# @param port
#   The port to use.
#
# @param role
#   The replication role.
#
# @param security
#   A hash containing the security configuration, includes users and roles.
#
# @param service_enable
#   Specifies whether the service should be enabled for this instance.
#
# @param service_ensure
#   Specifies the desired service state for this instance.
#
# @param target_host
#   Specifies the target host where this instance should be installed.
#   The value will be matched against `$facts['networking']['fqdn']`.
#   This is especially useful for cluster configurations.
#
# @param vote_on_replication_failure
#   Configuration for classic replication (not needed for Pluggable Quorum Vote Replication).
#
# @param web_bind
#   The host name to use for embedded web server.
#
# @param web_port
#   The port to use for embedded web server.
#
define activemq::instance (
  Hash[String[1], Hash] $acceptors,
  Array $acceptor_settings,
  Hash[String[1], Hash] $address_settings,
  Hash[String[1], Hash] $addresses,
  Boolean $allow_direct_connections_only,
  Boolean $allow_failback,
  String $bind,
  Array $broadcast_groups,
  Hash[String[1], Hash] $broker_plugins,
  Boolean $check_for_live_server,
  Hash[String[1], Hash] $connectors,
  Array $discovery_groups,
  Boolean $failover_on_shutdown,
  Integer $initial_replication_sync_timeout,
  Hash $jmx,
  Integer $journal_buffer_timeout,
  Boolean $journal_datasync,
  Integer $journal_max_io,
  Enum['asyncio','mapped','nio'] $journal_type,
  Hash $log_level,
  Hash $log4j_level,
  String $management_notification_address,
  Integer $max_disk_usage,
  Integer $max_hops,
  Enum['off','strict','on_demand'] $message_load_balancing,
  Boolean $persistence,
  Integer $port,
  Enum['master','slave'] $role,
  Hash $security,
  Boolean $vote_on_replication_failure,
  String $web_bind,
  Integer $web_port,
  Hash $java_args = $activemq::java_args,
  String $java_xms = $activemq::java_xms,
  String $java_xmx = $activemq::java_xmx,
  # Optional parameters
  Optional[Integer] $global_max_size_mb = undef,
  Optional[String] $group = undef,
  Optional[Boolean] $service_enable = undef,
  Optional[Enum['running','stopped']] $service_ensure = undef,
  Optional[String] $target_host = undef,
  Optional[Enum['live-only','replication','shared-storage']] $ha_policy = undef,
  # TODO: broker-plugins (nothing set by default, but it should be supported)
) {
  File {
    owner => $activemq::user,
    group => $activemq::group,
  }

  # Check if this instance should be installed on this host.
  if (empty($target_host) or ($target_host == $facts['networking']['fqdn'])) {
    # Construct paths and filenames for this insance.
    $instance_dir = "${activemq::instances_base}/${name}"
    $bootstrap_xml = "${instance_dir}/etc/bootstrap.xml"
    $broker_xml = "${instance_dir}/etc/broker.xml"
    $management_xml = "${instance_dir}/etc/management.xml"
    $jolokia_access_xml = "${instance_dir}/etc/jolokia-access.xml"
    $log4j_properties = "${instance_dir}/etc/log4j2.properties"
    $logging_properties = "${instance_dir}/etc/logging.properties"
    $login_config = "${instance_dir}/etc/login.config"
    $instance_service = "${activemq::service_name}@${name}"
    $installer_cmd = "${activemq::install_base}/${activemq::symlink_name}/bin/artemis"
    $roles_properties = "${instance_dir}/etc/artemis-roles.properties"
    $users_properties = "${instance_dir}/etc/artemis-users.properties"
    $artemis_profile = "${instance_dir}/etc/artemis.profile"

    # Command to create new instances.
    # NOTE: We pass all parameters, although we will replace the configuration
    # in a later step anways. We do this to validate whether or not these options
    # are still supported in the selected release of ActiveMQ Artemis. The
    # installer will fail on unsupported options.
    $create_command = join([
        $installer_cmd,
        'create',
        $instance_dir,
        '--aio',
        '--autocreate',
        '--clustered',
        '--replicated',
        "--cluster-user \'${activemq::cluster_user}\'",
        "--cluster-password \'${activemq::cluster_password}\'",
        "--name ${name}",
        "--host ${bind}",
        '--require-login',
        "--user \'${activemq::admin_user}\'",
        "--password \'${activemq::admin_password}\'",
    ], ' ')

    # Run installer to create a new instance
    exec { "create instance ${name}" :
      user    => $activemq::user,
      group   => $activemq::group,
      path    => '/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin',
      cwd     => $activemq::instances_base,
      # Run this exec only if no old instance can be found.
      unless  => "test -d \'${instance_dir}\'",
      command => $create_command,
      # Run this exec only if installer can be found.
      onlyif  => "test -f \'${installer_cmd}\'",
      require => [
        Class['activemq::install'],
      ],
      notify  => [
        Service[$instance_service],
      ],
    }

    # Iterate over all acceptors to validate and update their configuration.
    # This keeps this complexity away from the templates.
    $_acceptors = $acceptors.reduce({}) |$memo, $x| {
      # A nested hash contains the configuration.
      if ($x[1] =~ Hash) {
        # Fail if basic information is missing.
        if ( !('port' in $x[1]) or !('protocols' in $x[1]) ) {
          fail("Invalid \$acceptors configuration, no value for \$port or \$protocols in acceptor ${x[0]} for instance ${name}.")
        }

        # Ensure that all protocol names use uppercase letters.
        $_protocols = $x[1]['protocols'].reduce([]) |$m, $y| {
          $m + [upcase($y)]
        }

        # Generate a comma separated list of acceptor protocols.
        $_protocols_list = join($_protocols, ',')

        # Check if general "acceptor_settings" option can be found.
        if ( 'acceptor_settings' in $x[1] ) {
          # Merge more specific 'settings' with general 'acceptor_settings'.
          if ( 'settings' in $x[1] ) {
            $_settings = $x[1]['settings'] + $x[1]['acceptor_settings']
          } else {
            $_settings = $x[1]['acceptor_settings']
          }
        } else {
          # No "acceptor_settings", only use 'settings' if available.
          if ( 'settings' in $x[1] ) {
            $_settings = $x[1]['settings']
          } else {
            $_settings = []
          }
        }

        # Generate a semicolon separated list of acceptor settings.
        $_settings_list = join($_settings, ';')

        # Finally merge with all other options.
        $_values = $x[1].deep_merge({
            'protocols_list' => $_protocols_list,
            'settings' => $_settings,
            'settings_list' => $_settings_list,
        })
      } else {
        fail("Invalid \$acceptors configuration, expected a Hash but got something else in acceptor ${x[0]} for instance ${name}.")
      }
      $memo + { $x[0] => $_values }
    }

    # Iterate over all broker plugins. Only enabled plugins will be passed
    # to the template.
    $_broker_plugins = $broker_plugins.reduce({}) |$memo, $x| {
      # A nested hash contains the configuration.
      if ($x[1] =~ Hash) {
        # Fail if basic information is missing.
        if (!('enable' in $x[1]) or !($x[1]['enable'] =~ Boolean)) {
          fail("Invalid \$broker_plugins configuration, invalid or missing value for \$enable in plugin ${x[0]} for instance ${name}.")
        }
        if ($x[1]['enable'] == true) {
          $memo + { $x[0] => $x[1] }
        }
      } else {
        fail("Invalid \$broker_plugins configuration, expected a Hash but got something else in plugin ${x[0]} for instance ${name}.")
      }
    }

    # Get a list of all role/user mappings.
    if (('users' in $security) and ($security['users'] =~ Hash)) {
      # Iterate over all users to find roles.
      $_roles = $security['users'].reduce([]) |$memo, $x| {
        # A nested hash contains the user configuration.
        if ($x[1] =~ Hash) {
          # Skip users that are not enabled.
          if (('enable' in $x[1]) and ($x[1]['enable'] == true) and ('roles' in $x[1])) {
            # Get all roles from this user.
            $_roles_tmp = $x[1]['roles'].reduce([]) |$m2, $z| {
              # Only add roles that are in use (=enabled).
              if (($z[0] =~ String) and ($z[1] =~ Boolean) and ($z[1] == true)) {
                $m2 + $z[0]
              } else { $m2 }
            }
            if ($_roles_tmp =~ Array and !empty($_roles_tmp)) {
              $memo + $_roles_tmp
            } else { $memo }
          } else { $memo }
        } else {
          fail("Invalid \$security configuration, expected a Hash but got something else for user ${x[0]} for instance ${name}.")
        }
      }.unique()

      # Next iterate over all roles and collect their users.
      $_role_mappings = $_roles.reduce({}) |$memo, $x| {
        $_users_tmp = $security['users'].reduce([]) |$m, $z| {
          # Skip users that are not enabled.
          if (('enable' in $z[1]) and ($z[1]['enable'] == true) and ('roles' in $z[1])) {
            # Check if role can be found for this user and is enabled.
            if ($x in $z[1]['roles']) {
              $m + $z[0]
            } else { $m }
          } else { $m }
        }
        $memo + { $x => $_users_tmp }
      }
    } else {
      # Default values to keep everyone happy.
      $_roles = []
      $_role_mappings = {}
    }

    # The contents of the subscribe/require parameters depends
    # on the ActiveMQ Artemis version number.
    $_service_subscribe_pre = [
      Class['activemq::install'],
      File["instance ${name} broker.xml"],
      File["instance ${name} management.xml"],
      File["instance ${name} bootstrap.xml"],
      File["instance ${name} jolokia-access.xml"],
      File["instance ${name} login.config"],
      File_line["instance ${name} set HAWTIO_ROLE"],
      File_line["instance ${name} set JAVA_ARGS"],
    ]
    $_service_require_pre = [
      File["instance ${name} broker.xml"],
      File["instance ${name} management.xml"],
      File["instance ${name} bootstrap.xml"],
      File["instance ${name} jolokia-access.xml"],
      File["instance ${name} login.config"],
      File_line["instance ${name} set HAWTIO_ROLE"],
      File_line["instance ${name} set JAVA_ARGS"],
    ]

    # Create broker.xml configuration file.
    file { "instance ${name} broker.xml":
      path    => $broker_xml,
      mode    => '0640',
      content => epp($activemq::broker_template, {
          'acceptors'                        => $_acceptors,
          'address_settings'                 => $address_settings,
          'addresses'                        => $addresses,
          'allow_failback'                   => $allow_failback,
          'allow_direct_connections_only'    => $allow_direct_connections_only,
          'bind'                             => $bind,
          'broadcast_groups'                 => $broadcast_groups,
          'broker_plugins'                   => $_broker_plugins,
          'check_for_live_server'            => $check_for_live_server,
          'cluster_password'                 => $activemq::cluster_password,
          'cluster_user'                     => $activemq::cluster_user,
          'connectors'                       => $connectors,
          'discovery_groups'                 => $discovery_groups,
          'failover_on_shutdown'             => $failover_on_shutdown,
          'global_max_size_mb'               => $global_max_size_mb,
          'group'                            => $group,
          'ha_policy'                        => $ha_policy,
          'initial_replication_sync_timeout' => $initial_replication_sync_timeout,
          'journal_buffer_timeout'           => $journal_buffer_timeout,
          'journal_datasync'                 => $journal_datasync,
          'journal_max_io'                   => $journal_max_io,
          'journal_type'                     => upcase($journal_type),
          'management_notification_address'  => $management_notification_address,
          'max_disk_usage'                   => $max_disk_usage,
          'max_hops'                         => $max_hops,
          'message_load_balancing'           => upcase($message_load_balancing),
          'name'                             => $name,
          'persistence'                      => $persistence,
          'port'                             => $port,
          'role'                             => $role,
          'security'                         => $security,
          'vote_on_replication_failure'      => $vote_on_replication_failure,
      }),
      require => [
        Exec["create instance ${name}"]
      ],
    }

    # Create management.xml configuration file.
    file { "instance ${name} management.xml":
      path    => $management_xml,
      mode    => '0640',
      content => epp($activemq::management_template, {
          'security' => $security,
      }),
      require => [
        Exec["create instance ${name}"]
      ],
    }

    # Create bootstrap.xml configuration file.
    file { "instance ${name} bootstrap.xml":
      path    => $bootstrap_xml,
      mode    => '0644',
      content => epp($activemq::bootstrap_template, {
          'broker_xml' => $broker_xml,
          'web_bind'   => $web_bind,
          'web_port'   => $web_port,
      }),
      require => [
        Exec["create instance ${name}"]
      ],
    }

    # Create jolokia-access.xml configuration file.
    file { "instance ${name} jolokia-access.xml":
      path    => $jolokia_access_xml,
      mode    => '0644',
      content => epp($activemq::jolokia_access_template, {
          'jmx' => $jmx,
      }),
      require => [
        Exec["create instance ${name}"]
      ],
    }

    # Create appropiate logging configuration.
    if (versioncmp($activemq::version, '2.27.0') >= 0) {
      # Recent versions use the log4j2.properties configuration file.
      file { "instance ${name} log4j2.properties":
        path    => $log4j_properties,
        mode    => '0644',
        content => epp($activemq::log4j_template, {
            'log4j_level' => $log4j_level,
        }),
        require => [
          Exec["create instance ${name}"]
        ],
      }
      # Update service subscribe/require parameters.
      $_service_subscribe = $_service_subscribe_pre + [File["instance ${name} log4j2.properties"]]
      $_service_require = $_service_require_pre + [File["instance ${name} log4j2.properties"]]
    } else {
      # Older versions use the logging.properties configuration file.
      file { "instance ${name} logging.properties":
        path    => $logging_properties,
        mode    => '0644',
        content => epp($activemq::logging_template, {
            'log_level' => $log_level,
        }),
        require => [
          Exec["create instance ${name}"]
        ],
      }
      # Update service subscribe/require parameters.
      $_service_subscribe = $_service_subscribe_pre + [File["instance ${name} logging.properties"]]
      $_service_require = $_service_require_pre + [File["instance ${name} logging.properties"]]
    }

    # Create login.config file.
    file { "instance ${name} login.config":
      path    => $login_config,
      mode    => '0644',
      content => epp($activemq::login_template),
      require => [
        Exec["create instance ${name}"]
      ],
    }

    # Create artemis-users.properties file.
    if ($activemq::manage_users) {
      file { "instance ${name} artemis-users.properties":
        path    => $users_properties,
        mode    => '0644',
        content => epp($activemq::users_properties_template, {
            'admin_password' => $activemq::admin_password,
            'admin_user'     => $activemq::admin_user,
            'security'       => $security,
        }),
        require => [
          Exec["create instance ${name}"]
        ],
        before  => [
          Service[$instance_service],
        ],
        notify  => [
          Service[$instance_service],
        ],
      }
    }

    # Create artemis-roles.properties file.
    if ($activemq::manage_roles) {
      file { "instance ${name} artemis-roles.properties":
        path    => $roles_properties,
        mode    => '0644',
        content => epp($activemq::roles_properties_template, {
            'admin_user'    => $activemq::admin_user,
            'role_mappings' => $_role_mappings,
            'security'      => $security,
        }),
        require => [
          Exec["create instance ${name}"]
        ],
        before  => [
          Service[$instance_service],
        ],
        notify  => [
          Service[$instance_service],
        ],
      }
    }

    if (versioncmp($activemq::version, '2.42.0') >= 0) {
      # Remove obsolete variables from profile.
      file_line { "instance ${name} remove ARTEMIS_INSTANCE_URI":
        ensure            => 'absent',
        path              => $artemis_profile,
        match             => '^ARTEMIS_INSTANCE_URI=',
        match_for_absence => true,
        require           => [
          Exec["create instance ${name}"]
        ],
      }
      file_line { "instance ${name} remove ARTEMIS_INSTANCE_ETC_URI":
        ensure            => 'absent',
        path              => $artemis_profile,
        match             => '^ARTEMIS_INSTANCE_ETC_URI=',
        match_for_absence => true,
        require           => [
          Exec["create instance ${name}"]
        ],
      }
      file_line { "instance ${name} remove ARTEMIS_ETC_DIR":
        ensure            => 'absent',
        path              => $artemis_profile,
        match             => '^ARTEMIS_ETC_DIR=',
        match_for_absence => true,
        require           => [
          Exec["create instance ${name}"]
        ],
      }
    }

    # Configure HAWTIO role.
    file_line { "instance ${name} set HAWTIO_ROLE":
      ensure             => 'present',
      path               => $artemis_profile,
      line               => "HAWTIO_ROLE=\'${$activemq::hawtio_role}\'",
      match              => '^HAWTIO_ROLE=',
      append_on_no_match => false,
      require            => [
        Exec["create instance ${name}"]
      ],
    }

    # Configure ARTEMIS_HOME.
    file_line { "instance ${name} set ARTEMIS_HOME":
      ensure             => 'present',
      path               => $artemis_profile,
      line               => "ARTEMIS_HOME=\'${$activemq::install_base}/${$activemq::symlink_name}\'",
      match              => '^ARTEMIS_HOME=',
      append_on_no_match => false,
      require            => [
        Exec["create instance ${name}"]
      ],
    }

    # Configure JAVA_ARGS.
    $java_args_tmp = $java_args.reduce([]) |$memo, $x| {
      if (($x[1] =~ String) and $x[1] == 'DISABLED') {
        # ignore disabled options
        $memo
      } else {
        $memo + "-${x[0]}${x[1]}"
      }
    }
    $java_args_real = join($java_args_tmp, ' ')
    file_line { "instance ${name} set JAVA_ARGS":
      ensure             => 'present',
      path               => $artemis_profile,
      line               => "JAVA_ARGS=\"${java_args_real}\"",
      after              => '^# Java Opts',
      match              => '^JAVA_ARGS=',
      append_on_no_match => true,
      require            => [
        Exec["create instance ${name}"]
      ],
    }

    # Check if service should be enabled.
    $_service_enable = $service_enable ? {
      undef   => $activemq::service_enable,
      default => $service_enable,
    }
    $_service_ensure = $service_ensure ? {
      undef   => $activemq::service_ensure,
      default => $service_ensure,
    }

    # Configure service for this instance.
    service { $instance_service:
      ensure    => $_service_ensure,
      enable    => $_service_enable,
      subscribe => $_service_subscribe,
      require   => $_service_require,
    }
  }
}

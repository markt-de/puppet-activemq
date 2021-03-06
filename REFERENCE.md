# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

#### Public Classes

* [`activemq`](#activemq): Install and configure ActiveMQ Artemis

#### Private Classes

* `activemq::install`: Install ActiveMQ distribution archive
* `activemq::service`: Setup ActiveMQ multi-instance system service

### Defined types

* [`activemq::instance`](#activemqinstance): Create an instance of ActiveMQ Artemis broker

## Classes

### `activemq`

Install and configure ActiveMQ Artemis

#### Parameters

The following parameters are available in the `activemq` class.

##### `admin_password`

Data type: `String`

Specifies the password to use for standalone instances.

##### `admin_user`

Data type: `String`

Specifies the name of the user to use for standalone instances.

##### `checksum`

Data type: `Optional[String]`

Specifies the checksum for the distribution archive, which will be verified
after downloading the file and before starting the installation.

Default value: ``undef``

##### `checksum_type`

Data type: `Optional[String]`

Specifies the type of the checksum. Defaults to `sha512`.

Default value: ``undef``

##### `cluster`

Data type: `Boolean`

Whether to setup a cluster or a standalone instance.

##### `cluster_name`

Data type: `Optional[String]`

Specifies the name to use for the cluster.

Default value: ``undef``

##### `cluster_password`

Data type: `String`

Specifies the password to use for clustered instances.

##### `cluster_user`

Data type: `String`

Specifies the name of the user to use for clustered instances.

##### `cluster_topology`

Data type: `Hash[String[1], Hash]`

The topology of the cluster, which should contain ALL instances across the
whole cluster (not only local instances), their settings and relationships.

##### `distribution_name`

Data type: `String`

Specifies the name of the distribution, which is usually used to build
the actual download URL.

##### `download_url`

Data type: `String`

Specifies the download location. It should contain a `%s` string which
is automatically replaced with the actual filename during installation.
The latter makes it easier to use mirror redirection URLs.

##### `gid`

Data type: `Optional[Integer]`

Specifies an optional GID that should be used when creating the group.

Default value: ``undef``

##### `group`

Data type: `String`

Specifies the name of the group to use for the service/instance.

##### `install_base`

Data type: `Stdlib::Compat::Absolute_path`

Specifies the installation directory. This directory must already exist.
A subdirectory for every version is automatically created.

##### `instance_defaults`

Data type: `Hash`

The default parameters for all instances. They are merged with all
instance-specific parameters. This makes it obsolete to specify ALL
required parameters for every instance, but only parameters that differ
from these defaults.

##### `instances`

Data type: `Hash[String[1], Hash]`

A list of instances that should be created.

##### `instances_base`

Data type: `Stdlib::Compat::Absolute_path`

Specifies the directory where broker instances should be installed.
This directory must already exist. A subdirectory for every instance is
automatically created.

##### `manage_account`

Data type: `Boolean`

Whether or not to create the user and group.

##### `manage_instances_base`

Data type: `Boolean`

Whether or not to create the directory specified in `$instances_base`.

##### `manage_roles`

Data type: `Boolean`

Whether or not to manage ActiveMQ roles.

##### `manage_users`

Data type: `Boolean`

Whether or not to manage ActiveMQ users.

##### `port`

Data type: `Integer`

Specifies the port to use for the artemis connector and will also be used
as default port for the acceptor.

##### `server_discovery`

Data type: `Enum['dynamic','static']`

Controls how servers can propagate their connection details.

##### `service_enable`

Data type: `Boolean`

Specifies whether the service should be enabled.

##### `service_ensure`

Data type: `Enum['running','stopped']`

Specifies the desired state for the service.

##### `service_file`

Data type: `Stdlib::Compat::Absolute_path`

Specifies the filename of the service file.

##### `service_name`

Data type: `String`

Controls the name of the system service. Must NOT be changed while
instances are running.

##### `symlink_name`

Data type: `String`

Controls the name of a version-independent symlink. It will always point
to the release specified by `$version`.

##### `uid`

Data type: `Optional[Integer]`

Specifies an optional UID that should be used when creating the user.

Default value: ``undef``

##### `user`

Data type: `String`

Specifies the name of the user to use for the service/instance.

##### `version`

Data type: `String`

Specifies the version of ActiveMQ (Artemis) to install and use. No default
value is provided on purpose, to avoid prevent new users from using a
outdated version and to avoid unexpected updates by later changing the
default value.

##### `bootstrap_template`

Data type: `String`



##### `broker_template`

Data type: `String`



##### `logging_template`

Data type: `String`



##### `login_template`

Data type: `String`



##### `roles_properties_template`

Data type: `String`



##### `service_template`

Data type: `String`



##### `users_properties_template`

Data type: `String`



## Defined types

### `activemq::instance`

Create an instance of ActiveMQ Artemis broker

#### Parameters

The following parameters are available in the `activemq::instance` defined type.

##### `address_settings`

Data type: `Hash[String[1], Hash]`

A hash containing global address settings. This is especially useful
for wildcard/catch all matches.

##### `addresses`

Data type: `Hash[String[1], Hash]`

A hash containing configuration for addresses (messaging endpoints),
queues and routing types.

##### `bind`

Data type: `String`

Configure which IP address to listen on. Should be either a FQDN
or an IP address.

##### `broker_plugins`

Data type: `Hash[String[1], Hash]`

A hash containing a list of broker plugins and their configuration.
Each plugin can be enabled by setting `enable` to `true`.

##### `log_level`

Data type: `Hash`

The log levels to use for the various configured loggers.

##### `security`

Data type: `Hash`

A hash containing the security configuration, includes users and roles.

##### `service_enable`

Data type: `Optional[Boolean]`

Specifies whether the service should be enabled for this instance.

Default value: ``undef``

##### `service_ensure`

Data type: `Optional[Enum['running','stopped']]`

Specifies the desired service state for this instance.

Default value: ``undef``

##### `target_host`

Data type: `Optional[String]`

Specifies the target host where this instance should be installed.
The value will be matched against `$facts['networking']['fqdn']`.
This is especially useful for cluster configurations.

Default value: ``undef``

##### `web_bind`

Data type: `String`

The host name to use for embedded web server.

##### `web_port`

Data type: `Integer`

The port to use for embedded web server.

##### `acceptors`

Data type: `Hash[String[1], Hash]`



##### `acceptor_settings`

Data type: `Array`



##### `allow_failback`

Data type: `Boolean`



##### `broadcast_groups`

Data type: `Array`



##### `check_for_live_server`

Data type: `Boolean`



##### `connectors`

Data type: `Hash[String[1], Hash]`



##### `discovery_groups`

Data type: `Array`



##### `failover_on_shutdown`

Data type: `Boolean`



##### `ha_policy`

Data type: `Enum['live-only','replication','shared-storage']`



##### `initial_replication_sync_timeout`

Data type: `Integer`



##### `journal_buffer_timeout`

Data type: `Integer`



##### `journal_datasync`

Data type: `Boolean`



##### `journal_max_io`

Data type: `Integer`



##### `journal_type`

Data type: `Enum['asyncio','mapped','nio']`



##### `max_disk_usage`

Data type: `Integer`



##### `max_hops`

Data type: `Integer`



##### `message_load_balancing`

Data type: `Enum['off','strict','on_demand']`



##### `persistence`

Data type: `Boolean`



##### `port`

Data type: `Integer`



##### `role`

Data type: `Enum['master','slave']`



##### `vote_on_replication_failure`

Data type: `Boolean`



##### `global_max_size_mb`

Data type: `Optional[Integer]`



Default value: ``undef``

##### `group`

Data type: `Optional[String]`



Default value: ``undef``


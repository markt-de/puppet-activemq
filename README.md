# puppet-activemq

[![Build Status](https://github.com/markt-de/puppet-activemq/actions/workflows/ci.yaml/badge.svg)](https://github.com/markt-de/puppet-activemq/actions/workflows/ci.yaml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/markt/activemq.svg)](https://forge.puppetlabs.com/markt/activemq)
[![Puppet Forge](https://img.shields.io/puppetforge/f/markt/activemq.svg)](https://forge.puppetlabs.com/markt/activemq)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Usage](#usage)
    - [Basic usage](#basic-usage)
    - [Multiple instances](#multiple-instances)
    - [Clusters](#clusters)
    - [Security, Roles, Users and Queues](#security-roles-users-and-queues)
    - [Custom configuration](#custom-configuration)
1. [Reference](#reference)
1. [Limitations](#limitations)
1. [Development](#development)
    - [Contributing](#contributing)

## Overview

A puppet module to install and configure ActiveMQ Artemis.

*PLEASE NOTE:* Legacy ActiveMQ is NOT supported by this module.

## Requirements

A working Java installation is required ([puppetlabs-java](https://github.com/puppetlabs/puppetlabs-java/) is highly recommended).
The module is designed for Hiera, so there may be some rough edges when used without Hiera.

## Usage

### Basic usage

The minimum configuration should at least specify the admin password, the desired version and the checksum of the distribution archive (bin.tar.gz).
The checksum is available from ActiveMQ's [download page](https://activemq.apache.org/components/artemis/download/).

```puppet
class { 'java': }
class { 'activemq':
  admin_password => 'seCReT',
  admin_user => 'admin',
  checksum => 'a73331cb959bb0ba9667414682c279bc9ce2aec4c8fecbcdee4670bf9d63bf66010c8c55a6b727b1ad6d51bbccadd663b96a70b867721d9388d54a9391c6af85',
  instances => {'activemq' => {}},
  version => '2.23.1',
}
```

This will install and configure a standalone instance of ActiveMQ Artemis.

### Multiple instances

Multiple instances can be setup like this:

```puppet
$instances = {
  'instance1' => {
    bind => '127.0.0.1',
    port => 61616,
    web_port => 8161,
    acceptors => {
      artemis => { port => 61616 },
      amqp => { port => 5672 },
    },
  },
  'instance2' => {
    bind => '127.0.0.1',
    port => 62616,
    web_port => 8261,
    acceptors => {
      artemis => { port => 62616 },
      amqp => { port => 5772 },
    },
  },
  'instance3' => {
    bind => '127.0.0.1',
    port => 63616,
    web_port => 8361,
    acceptors => {
      artemis => { port => 63616 },
      amqp => { port => 5872 },
    },
  }
}

class { 'java': }
class { 'activemq':
  checksum => 'a73331cb959bb0ba9667414682c279bc9ce2aec4c8fecbcdee4670bf9d63bf66010c8c55a6b727b1ad6d51bbccadd663b96a70b867721d9388d54a9391c6af85',
  instances => $instances,
  version => '2.23.1',
}
```

Note that you need to modify the port numbers for each instance when running on the same host (as demonstrated in this example), so that they do not try to bind on the same IP:PORT combination.

Instead of using the `$instances` parameter, the defined type can also be used directly:

```puppet
activemq::instance { 'test1':
  bind => $facts['networking']['ip'],
  port => 61616,
  ...
}
```

But contrary to the `$instances` parameter, all required parameters have to be provided when using the defined type directly.

### Clusters

Complex cluster configurations are also supported. You should provide a complete `$cluster_topology` on every node. Use `target_host` to let the module automatically setup the instances on the correct servers. For example:

```puppet
$cluster_topology = {
  'node1' => {
    target_host => 'server1.example.com',
    bind => '10.0.0.1',
    group => 'green'
  },
  'node2' => {
    target_host => 'server3.example.com',
    bind => '10.0.0.2',
    group => 'green',
    role => 'slave'
  },
  'node3' => {
    target_host => 'server2.example.com',
    bind => '10.0.0.3',
    group => 'yellow'
  },
  'node4' => {
    target_host => 'server1.example.com',
    bind => '10.0.0.4',
    group => 'yellow',
    role => 'slave'
  },
  'node5' => {
    target_host => 'server3.example.com',
    bind => '10.0.0.5',
    group => 'white'
  },
  'node6' => {
    target_host => 'server2.example.com',
    bind => '10.0.0.6',
    group => 'white',
    role => 'slave'
  },
}

class { 'java': }
class { 'activemq':
  checksum => '84b5a65d8eb2fc8cf3f17df524d586b0c6a2acfa9a09089d5ffdfc1323ff99dfdc775b2e95eec264cfeddc4742839ba9b0f3269351a5c955dd4bbf6d5ec5dfa9',
  cluster => true,
  cluster_name => 'cluster001',
  cluster_password => 'seCReT'
  cluster_user => 'clusteradmin'
  cluster_topology => $cluster_topology,
  instances => $cluster_topology,
  server_discovery => 'static',
  version => '2.14.0',
}
```

Note that the parameters `$cluster_topology` and `$instances` both use the same values. If this configuration is used on host `server1.example.com`, then the module ensures that only instances `node1` and `node4` are installed, all other instances are ignored and will be installed only on the specified target host.

Also note that this examples assumes that each instance is running on it's own IP address. If multiple instances share the same IP address you need to change the port numbers to avoid conflicts (see "Multiple instances").

The `$cluster_topology` parameter is also used by the module to setup communication between cluster nodes (depending on your configuration).

### Security, Roles, Users and Queues

The instance configuration can be changed by using the required parameter or by modifying `$activemq::instance_defaults` (which will apply to all instances). The module data contains pretty verbose examples on how to configure queues, roles and users. Please open a GitHub issue if these examples require further explanation.

### Custom configuration

The module should provide a sane default configuration for many use-cases, but overriding these values for all instances is pretty easy:

```puppet
class { 'activemq':
  instance_defaults => {
    acceptors => {
      artemis => {
        enable => false,
      },
      stomp => {
        enable => true,
      },
    },
    acceptor_settings => [
      'tcpSendBufferSize=1048576',
    ],
    allow_failback => false,
    check_for_live_server => false,
    max_hops => 2,
  },
}
```

Please have a look at the examples in the module data to find all supported settings.

The module is designed for Hiera so it is highly recommended if you need to change the default configuration.

## Reference

Classes and parameters are documented in [REFERENCE.md](REFERENCE.md).

## Limitations

Upgrades of ActiveMQ Artemis are supported to a certain degree, provided that the new version is compatible with this module. Please note that in-place upgrades are performed and the official upgrade script is not used. This may have unwanted side-effect. Overall this upgrade procedure should be pretty safe for multi-instance primary/backup setups.

## Development

### Contributing

Please use the GitHub issues functionality to report any bugs or requests for new features. Feel free to fork and submit pull requests for potential contributions.

All contributions must pass all existing tests, new features should provide additional unit/acceptance tests.

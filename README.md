# puppet-activemq

[![Build Status](https://travis-ci.org/markt-de/puppet-activemq.png?branch=master)](https://travis-ci.org/markt-de/puppet-activemq)
[![Puppet Forge](https://img.shields.io/puppetforge/v/fraenki/activemq.svg)](https://forge.puppetlabs.com/fraenki/activemq)
[![Puppet Forge](https://img.shields.io/puppetforge/f/fraenki/activemq.svg)](https://forge.puppetlabs.com/fraenki/activemq)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Usage](#usage)
    - [Basic usage](#basic-usage)
    - [Multiple instances](#multiple-instances)
    - [Clusters](#clusters)
    - [Custom configuration](#custom-configuration)
1. [Reference](#reference)
1. [Development](#development)
    - [Contributing](#contributing)
    - [Fork](#fork)

## Overview

A puppet module to install and configure ActiveMQ Artemis.

*PLEASE NOTE:* Legacy ActiveMQ is NOT supported by this module.

## Requirements

A working Java installation is required ([puppetlabs-java](https://github.com/puppetlabs/puppetlabs-java/) is highly recommended).
The module is designed for Hiera, so there may be some rough edges when used without Hiera.

## Usage

### Basic usage

The minimum configuration should at least specify the desired version and the checksum of the distribution archive.
The checksum is available from ActiveMQ's download page.

```puppet
class { 'java': }
class { 'activemq':
  checksum => '84b5a65d8eb2fc8cf3f17df524d586b0c6a2acfa9a09089d5ffdfc1323ff99dfdc775b2e95eec264cfeddc4742839ba9b0f3269351a5c955dd4bbf6d5ec5dfa9',
  version => '2.14.0',
}
```

The will install and configure a standalone instance of ActiveMQ Artemis.

### Multiple instances

Multiple instances can be setup like this:

```puppet
$instances = {
  'instance1' => { bind => '127.0.0.1', port => 61616 },
  'instance2' => { bind => '127.0.0.1', port => 62616 },
  'instance3' => { bind => '127.0.0.1', port => 63616 },
}

class { 'java': }
class { 'activemq':
  checksum => '84b5a65d8eb2fc8cf3f17df524d586b0c6a2acfa9a09089d5ffdfc1323ff99dfdc775b2e95eec264cfeddc4742839ba9b0f3269351a5c955dd4bbf6d5ec5dfa9',
  instances => $instances,
  version => '2.14.0',
}
```

Instead of using the `$instances` parameter, the defined type can also be used directly:

```puppet
activemq::instance { 'test1':
  bind => $facts['networking']['ip'],
  port => 61616,
}
```

### Clusters

Complex cluster configurations are also supported. You should provide a complete `$cluster_topology` on every node. Use `target_host` to let the module automatically setup the instances on the correct servers. For example:

```puppet
$cluster_topology = {
  'node1' => { target_host => 'server1.example.com', bind => '10.0.0.1', group => 'green' },
  'node2' => { target_host => 'server3.example.com', bind => '10.0.0.2', group => 'green', role => 'slave' },
  'node3' => { target_host => 'server2.example.com', bind => '10.0.0.3', group => 'yellow' },
  'node4' => { target_host => 'server1.example.com', bind => '10.0.0.4', group => 'yellow', role => 'slave' },
  'node5' => { target_host => 'server3.example.com', bind => '10.0.0.5', group => 'white' },
  'node6' => { target_host => 'server2.example.com', bind => '10.0.0.6', group => 'white', role => 'slave' },
}

class { 'java': }
class { 'activemq':
  checksum => '84b5a65d8eb2fc8cf3f17df524d586b0c6a2acfa9a09089d5ffdfc1323ff99dfdc775b2e95eec264cfeddc4742839ba9b0f3269351a5c955dd4bbf6d5ec5dfa9',
  cluster => true,
  cluster_name => 'cluster001',
  cluster_topology => $cluster_topology,
  instances => $cluster_topology,
  server_discovery => 'static',
  version => '2.14.0',
}
```

Note that the parameters `$cluster_topology` and `$instances` both use the same values. If this configuration is used on host `server1.example.com`, then the module ensures that only instances `node1` and `node4` are installed, all other instances are ignored and will be installed only on the specified target host.

The `$cluster_topology` parameter is also used by the module to setup communication between cluster nodes (depending on your configuration).

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

The module is designed for Hiera so it is highly recommended if you need to change the default configuration.

## Reference

Classes and parameters are documented in [REFERENCE.md](REFERENCE.md).

## Development

### Contributing

Please use the GitHub issues functionality to report any bugs or requests for new features. Feel free to fork and submit pull requests for potential contributions.

All contributions must pass all existing tests, new features should provide additional unit/acceptance tests.

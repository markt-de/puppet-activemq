# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unrelease]
This is a new major release which may contain breaking changes for some
users, because it may replace existing configuration with new default
values.

### Added
* Add new parameter `$management_notification_address`
* Add support for managing Jolokia allow-origin CORS option

### Changed
* Do not produce a HA policy config when `$ha_policy` is empty ([#6])
* Manage `jolokia-access.xml`, existing file will be replaced
* Add defaults for `config-delete-*` to address settings
* Set a default management notification address
* Update Puppet version requirements

## [v1.6.0] - 2023-07-24

### Added
* Ensure compatibility with version 2.29.0
* Add new parameter `$log4j_template`
* Add new instance parameter `$log4j_level`
* Add new default logging config for log4j2

### Changed
* Manage `log4j2.properties` on version 2.27.0 and later
* Manage `logging properties` only on versions before 2.27.0
* Update to PDK 3.0
* Bump module dependencies

### Fixed
* Fix GitHub Actions
* Fix compatibility with puppetlabs/stdlib v9.0.0

## [v1.5.0] - 2022-10-24

### Fixed
* Fix resource not found when disabling user/role management
* Fix service not restarting when changing bootstrap/logging/login config

## [v1.4.0] - 2022-10-19

### Added
* Add new parameters: `$java_args`, `$java_xms`, `$java_xmx`
* Add basic unit/acceptance tests
* Add documentation for all parameters

### Changed
* Manage custom JAVA_ARGS in artemis.profile
* Enable allow-failback for all HA policies (not restricted to shared storage anymore)

### Fixed
* Fix failed validation when setting `$cluster=false`
* Do not try to 'enable' the systemd unit template (fails on recent systemd versions)

## [v1.3.0] - 2022-07-27

### Added
* Add possibility to install behind proxy ([#2])
* Ensure compatibility with version 2.21.0 and later
* Add support for updating ActiveMQ Artemis

### Changed
* Adopt namespace changes in bootstrap.xml and management.xml (backwards-compatible)
* Set variable ARTEMIS_HOME to symlink location in artemis.profile
* Update OS support, module dependencies and PDK

### Fixed
* Fix puppet-lint offenses

## [v1.2.0] - 2021-09-02

### Added
* Add possibility to setup connectors for the Artemis Management API

## [v1.1.0] - 2021-08-31

### Added
* Let Puppet maintain `management.xml` (existing config will be overwritten)
* Add new parameter `$hawtio_role` to manage HAWTIO_ROLE in artemis.profile

### Changed
* Update to PDK 2.2.0
* Update dependency and Puppet version requirements

## v1.0.0 - 2020-10-06
Initial release

[Unreleased]: https://github.com/markt-de/puppet-activemq/compare/v1.6.0...HEAD
[v1.6.0]: https://github.com/markt-de/puppet-activemq/compare/v1.5.0...v1.6.0
[v1.5.0]: https://github.com/markt-de/puppet-activemq/compare/v1.4.0...v1.5.0
[v1.4.0]: https://github.com/markt-de/puppet-activemq/compare/v1.3.0...v1.4.0
[v1.3.0]: https://github.com/markt-de/puppet-activemq/compare/v1.2.0...v1.3.0
[v1.2.0]: https://github.com/markt-de/puppet-activemq/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/markt-de/puppet-activemq/compare/v1.0.0...v1.1.0
[#6]: https://github.com/markt-de/puppet-activemq/pull/6
[#2]: https://github.com/markt-de/puppet-activemq/pull/2

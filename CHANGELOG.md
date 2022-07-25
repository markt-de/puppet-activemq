# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
* Add possibility to install behind proxy ([#2])
* Add compatibility with version 2.21.0 and later

### Changed
* Adopt namespace changes in bootstrap.xml and management.xml (backwards-compatible)
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

[Unreleased]: https://github.com/markt-de/puppet-activemq/compare/v1.2.0...HEAD
[v1.2.0]: https://github.com/markt-de/puppet-activemq/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/markt-de/puppet-activemq/compare/v1.0.0...v1.1.0
[#2]: https://github.com/markt-de/puppet-activemq/pull/2

# Changelog

## Unreleased
- None

## [0.1.18](releases/tag/v0.1.18) - 2018-01-05
### Added
- [#29] Support for im.create and im.counters ([@christianmoretti][])

## [0.1.17](releases/tag/v0.1.17) - 2019-01-05
### Deprecation
- Drop Ruby 2.1 from build matrix

## [0.1.16](releases/tag/v0.1.16) - 2018-10-3
### Deprecation
- Drop Ruby 2.0 from build matrix

### Added
- [#27] Support for channels.online ([@chrisstime][])
- `rubocop-rspec` dependency and fixed new lints

## [0.1.15](releases/tag/v0.1.15) - 2017-12-21
### Fixed
- Updated yard to resolve potential security vulnerability

## [0.1.14](releases/tag/v0.1.14) - 2017-10-9
### Added
- [#19] Room/channel kick function ([@hardik127][])

## [0.1.13](releases/tag/v0.1.13) - 2017-10-9
### Added
- Support for channel/group addAll endpoint

## [0.1.12](releases/tag/v0.1.12) - 2017-08-28
### Fixed
- GET request parameter encoding

## [0.1.11](releases/tag/v0.1.11) - 2017-08-22
### Fixed
- [#15] Response parser improvements ([@reist][],[@danischreiber][])
- [#17] Fixed a missing dependency issue with `net/http`

### Added
- [#14] Add/remove moderator from room ([@danischreiber][])

## [0.1.10](releases/tag/v0.1.10) - 2017-07-31
### Added
- [#13] Allow query to be passed through for `list` requests ([@danischreiber][])

## [0.1.9](releases/tag/v0.1.9) - 2017-07-16
### Fixed
- Update chat message handlers to support Ruby 2.0

## [0.1.8](releases/tag/v0.1.8) - 2017-07-16
### Added
- Messages chat API support

## [0.1.7](releases/tag/v0.1.7) - 2017-07-16
### Added
- [#10] Archive/unarchive room support ([@danischreiber][])

## [0.1.6](releases/tag/v0.1.6) - 2017-07-12
### Added
- [#8] Various channel/group (room) API support ([@reist][],[@danischreiber][])

## [0.1.5](releases/tag/v0.1.5) - 2017-07-9
### Added
- [#6] User createToken and resetAvatar endpoints ([@reist][])
- [#7] Support for debugging server calls ([@reist][])

## [0.1.4](releases/tag/v0.1.4) - 2017-07-9
### Fixed
- Fixed a missing dependency issue with `uri`

## [0.1.2](releases/tag/v0.1.2) - 2017-05-24
### Added
- [#3] Initial support for 'Room' endpoints ([@reist][])

## [0.1.1](releases/tag/v0.1.1) - 2017-05-1
### Added
- Support for settings get/set endpoints

## [0.0.8](releases/tag/v0.0.8) - 2017-04-30
### Added
- Support for Users `getPresence` endpoint

## [0.0.7](releases/tag/v0.0.7) - 2017-04-30
### Added
- Support for Users `list` endpoint

## [0.0.6](releases/tag/v0.0.6) - 2017-04-25
### Fixed
- [#2] Allow requests to include server options ([@reist][])

## [0.0.5](releases/tag/v0.0.5) - 2017-04-25
### Added
- [#1] Added Users `info` and `delete` endpoints ([@reist][])

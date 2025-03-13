# Changelog

## Unreleased
- None

## [0.3.1](releases/tag/v0.3.1) - 2025-03-13
### Fixed
- [#51] Fix deprecation in User#info fetching of user room ([@abrom][]) 

## [0.2.7](releases/tag/v0.2.7) - 2025-02-07
### Fixed
- [#50] Fix bug in group/channel online API where ID usage broken ([@abrom][])

## [0.2.6](releases/tag/v0.2.6) - 2025-01-14
### Added
- [#49] Add Ruby 3.4 support ([@abrom][])

## [0.2.5](releases/tag/v0.2.5) - 2024-04-15
### Added
- [#48] Add Ruby 3.3 support ([@reist][])

## [0.2.4](releases/tag/v0.2.4) - 2023-12-22
### Added
- [#47] Add content-type and filename params for file upload ([@MrRTI][])

## [0.2.3](releases/tag/v0.2.3) - 2023-08-22
### Added
- [#46] Add file upload support using rooms.upload endpoint ([@MrRTI][])

## [0.2.2](releases/tag/v0.2.2) - 2023-04-21
### Added
- [#43] Add Ruby 3.2 support ([@MrRTI][])
- [#44] Add support for thread messages ([@MrRTI][])

### Fixed
- [#45] Fixed some rubocop lints ([@abrom][])


## [0.2.1](releases/tag/v0.2.1) - 2022-12-19
### Fixed
- [#41] URL-encode param values in GET query strings ([@nmagedman][])

## [0.1.23](releases/tag/v0.1.23) - 2022-11-11
### Added
- [#40] Add set_attr options for announcement, custom_fields and default for channels/groups ([@reist][],[@nmagedman][])

## [0.1.22](releases/tag/v0.1.22) - 2022-07-21
### Fixed
- [#38] Fix room (channel/group) online API queries (use `query` instead of `roomId`) ([@abrom][])

## [0.1.21](releases/tag/v0.1.21) - 2021-08-30
### Added
- [#36] Improve support for various REST APIs ([@abrom][])

## [0.1.20](releases/tag/v0.1.20) - 2021-03-29
### Added
- [#34] Support for channels.members and groups.members ([@alinavancea][])

### Deprecation
- [#35] Drop Ruby 2.3 and 2.4 support ([@abrom][])

## [0.1.19](releases/tag/v0.1.19) - 2019-03-01
### Fixed
- Address CVE-2020-8130 - `rake` OS command injection vulnerability ([@abrom][])

## [0.1.18](releases/tag/v0.1.18) - 2018-01-05
### Added
- [#29] Support for im.create and im.counters ([@christianmoretti][])

## [0.1.17](releases/tag/v0.1.17) - 2019-01-05
### Deprecation
- Drop Ruby 2.1 from build matrix ([@abrom][])

## [0.1.16](releases/tag/v0.1.16) - 2018-10-03
### Deprecation
- Drop Ruby 2.0 from build matrix ([@abrom][])

### Added
- [#27] Support for channels.online ([@chrisstime][])
- [#28] `rubocop-rspec` dependency and fixed new lints ([@abrom][])

## [0.1.15](releases/tag/v0.1.15) - 2017-12-21
### Fixed
- Updated yard to resolve potential security vulnerability ([@abrom][])

## [0.1.14](releases/tag/v0.1.14) - 2017-10-09
### Added
- [#19] Room/channel kick function ([@hardik127][])

## [0.1.13](releases/tag/v0.1.13) - 2017-10-09
### Added
- Support for channel/group addAll endpoint ([@abrom][])

## [0.1.12](releases/tag/v0.1.12) - 2017-08-28
### Fixed
- GET request parameter encoding ([@abrom][])

## [0.1.11](releases/tag/v0.1.11) - 2017-08-22
### Fixed
- [#15] Response parser improvements ([@reist][],[@danischreiber][])
- [#17] Fixed a missing dependency issue with `net/http` ([@abrom][])

### Added
- [#14] Add/remove moderator from room ([@danischreiber][])

## [0.1.10](releases/tag/v0.1.10) - 2017-07-31
### Added
- [#13] Allow query to be passed through for `list` requests ([@danischreiber][])

## [0.1.9](releases/tag/v0.1.9) - 2017-07-16
### Fixed
- Update chat message handlers to support Ruby 2.0 ([@abrom][])

## [0.1.8](releases/tag/v0.1.8) - 2017-07-16
### Added
- Messages chat API support ([@abrom][])

## [0.1.7](releases/tag/v0.1.7) - 2017-07-16
### Added
- [#10] Archive/unarchive room support ([@danischreiber][])

## [0.1.6](releases/tag/v0.1.6) - 2017-07-12
### Added
- [#8] Various channel/group (room) API support ([@reist][],[@danischreiber][])

## [0.1.5](releases/tag/v0.1.5) - 2017-07-09
### Added
- [#6] User createToken and resetAvatar endpoints ([@reist][])
- [#7] Support for debugging server calls ([@reist][])

## [0.1.4](releases/tag/v0.1.4) - 2017-07-09
### Fixed
- Fixed a missing dependency issue with `uri` ([@abrom][])

## [0.1.2](releases/tag/v0.1.2) - 2017-05-24
### Added
- [#3] Initial support for 'Room' endpoints ([@reist][])

## [0.1.1](releases/tag/v0.1.1) - 2017-05-01
### Added
- Support for settings get/set endpoints ([@abrom][])

## [0.0.8](releases/tag/v0.0.8) - 2017-04-30
### Added
- Support for Users `getPresence` endpoint ([@abrom][])

## [0.0.7](releases/tag/v0.0.7) - 2017-04-30
### Added
- Support for Users `list` endpoint ([@abrom][])

## [0.0.6](releases/tag/v0.0.6) - 2017-04-25
### Fixed
- [#2] Allow requests to include server options ([@reist][])

## [0.0.5](releases/tag/v0.0.5) - 2017-04-25
### Added
- [#1] Added Users `info` and `delete` endpoints ([@reist][])

[@abrom]: https://github.com/abrom
[@reist]: https://github.com/reist
[@danischreiber]: https://github.com/danischreiber
[@hardik127]: https://github.com/hardik127
[@chrisstime]: https://github.com/chrisstime
[@christianmoretti]: https://github.com/christianmoretti
[@alinavancea]: https://github.com/alinavancea
[@nmagedman]: https://github.com/nmagedman
[@MrRTI]: https://github.com/MrRTi 

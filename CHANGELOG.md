# Change Log

## [0.15.2](https://github.com/chef/kitchen-inspec/tree/0.15.2) (2016-09-26)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.15.1...0.15.2)

**Merged pull requests:**

- add support for inspec 1.0 [\#104](https://github.com/chef/kitchen-inspec/pull/104) ([chris-rock](https://github.com/chris-rock))
- use double-quotes for rake bump\_version [\#102](https://github.com/chef/kitchen-inspec/pull/102) ([chris-rock](https://github.com/chris-rock))

## [v0.15.1](https://github.com/chef/kitchen-inspec/tree/v0.15.1) (2016-09-05)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.15.0...v0.15.1)

**Closed issues:**

- Kitchen verify/test fails when using the command resource with curl [\#100](https://github.com/chef/kitchen-inspec/issues/100)
- Default to \( progress | documentation \) format for test-kitchen inspec verifier [\#91](https://github.com/chef/kitchen-inspec/issues/91)

**Merged pull requests:**

- Require Ruby 2.1+ [\#99](https://github.com/chef/kitchen-inspec/pull/99) ([tas50](https://github.com/tas50))
- Switch from finstyle / rubocop to chefstyle [\#98](https://github.com/chef/kitchen-inspec/pull/98) ([tas50](https://github.com/tas50))
- Update winrm password key for winrm-v2 [\#94](https://github.com/chef/kitchen-inspec/pull/94) ([mwrock](https://github.com/mwrock))

## [v0.15.0](https://github.com/chef/kitchen-inspec/tree/v0.15.0) (2016-07-15)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.14.0...v0.15.0)

**Fixed bugs:**

- TTY issue with base AWS CentOS AMI [\#45](https://github.com/chef/kitchen-inspec/issues/45)

**Closed issues:**

- kitchen converge fails on ubuntu [\#81](https://github.com/chef/kitchen-inspec/issues/81)

**Merged pull requests:**

- Overwriting test\_base\_path to test/recipes instead of test/integration [\#95](https://github.com/chef/kitchen-inspec/pull/95) ([tyler-ball](https://github.com/tyler-ball))
- demonstrated utilizing an array of profile sources [\#90](https://github.com/chef/kitchen-inspec/pull/90) ([jeremymv2](https://github.com/jeremymv2))

## [v0.14.0](https://github.com/chef/kitchen-inspec/tree/v0.14.0) (2016-05-25)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.13.0...v0.14.0)

**Closed issues:**

- How to verify with a local profile [\#88](https://github.com/chef/kitchen-inspec/issues/88)

**Merged pull requests:**

- update readme with remote profile handling [\#89](https://github.com/chef/kitchen-inspec/pull/89) ([chris-rock](https://github.com/chris-rock))
- depend on inspec 0.22+ [\#87](https://github.com/chef/kitchen-inspec/pull/87) ([chris-rock](https://github.com/chris-rock))
- support for sudo\_command [\#86](https://github.com/chef/kitchen-inspec/pull/86) ([jeremymv2](https://github.com/jeremymv2))

## [v0.13.0](https://github.com/chef/kitchen-inspec/tree/v0.13.0) (2016-05-10)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.12.5...v0.13.0)

**Implemented enhancements:**

- Supermarket and Compliance support [\#84](https://github.com/chef/kitchen-inspec/pull/84) ([chris-rock](https://github.com/chris-rock))
- add more debug messages [\#82](https://github.com/chef/kitchen-inspec/pull/82) ([chris-rock](https://github.com/chris-rock))

**Fixed bugs:**

- Cannot run supermarket and compliance profiles [\#80](https://github.com/chef/kitchen-inspec/issues/80)

**Merged pull requests:**

- release via travis to rubygems on tags [\#79](https://github.com/chef/kitchen-inspec/pull/79) ([arlimus](https://github.com/arlimus))
- fix lint [\#77](https://github.com/chef/kitchen-inspec/pull/77) ([chris-rock](https://github.com/chris-rock))
- fix lint [\#76](https://github.com/chef/kitchen-inspec/pull/76) ([chris-rock](https://github.com/chris-rock))
- Add support for profiles\_path [\#75](https://github.com/chef/kitchen-inspec/pull/75) ([brettlangdon](https://github.com/brettlangdon))
- Add complete profile example to readme [\#73](https://github.com/chef/kitchen-inspec/pull/73) ([alexpop](https://github.com/alexpop))
- Use only the keys provided by Kitchen [\#72](https://github.com/chef/kitchen-inspec/pull/72) ([ehartmann](https://github.com/ehartmann))
- Support color flag [\#71](https://github.com/chef/kitchen-inspec/pull/71) ([jbussdieker](https://github.com/jbussdieker))

## [v0.12.5](https://github.com/chef/kitchen-inspec/tree/v0.12.5) (2016-03-17)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.12.4...v0.12.5)

**Merged pull requests:**

- 0.12.5 [\#69](https://github.com/chef/kitchen-inspec/pull/69) ([arlimus](https://github.com/arlimus))
- allow for slightly newer versions of inspec [\#68](https://github.com/chef/kitchen-inspec/pull/68) ([arlimus](https://github.com/arlimus))

## [v0.12.4](https://github.com/chef/kitchen-inspec/tree/v0.12.4) (2016-03-15)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.12.3...v0.12.4)

**Implemented enhancements:**

- InSpec Profile [\#46](https://github.com/chef/kitchen-inspec/issues/46)

**Fixed bugs:**

- `kitchen verify` fails on Windows [\#57](https://github.com/chef/kitchen-inspec/issues/57)

**Closed issues:**

- Unable to test installed Gems [\#65](https://github.com/chef/kitchen-inspec/issues/65)
- InSpec Profile support in kitchen-inspec [\#39](https://github.com/chef/kitchen-inspec/issues/39)

**Merged pull requests:**

- 0.12.4 [\#67](https://github.com/chef/kitchen-inspec/pull/67) ([chris-rock](https://github.com/chris-rock))
- add output to runner options [\#64](https://github.com/chef/kitchen-inspec/pull/64) ([vjeffrey](https://github.com/vjeffrey))
- Improve handling for remote profiles [\#63](https://github.com/chef/kitchen-inspec/pull/63) ([chris-rock](https://github.com/chris-rock))

## [v0.12.3](https://github.com/chef/kitchen-inspec/tree/v0.12.3) (2016-03-01)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.12.2...v0.12.3)

**Implemented enhancements:**

- fix gem build license warning [\#59](https://github.com/chef/kitchen-inspec/pull/59) ([chris-rock](https://github.com/chris-rock))
- Add support for remote profiles [\#51](https://github.com/chef/kitchen-inspec/pull/51) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.12.3 [\#61](https://github.com/chef/kitchen-inspec/pull/61) ([chris-rock](https://github.com/chris-rock))
- add test-kitchen 1.6 as dependency [\#60](https://github.com/chef/kitchen-inspec/pull/60) ([chris-rock](https://github.com/chris-rock))
- Bump berks requirement to latest [\#58](https://github.com/chef/kitchen-inspec/pull/58) ([jkeiser](https://github.com/jkeiser))

## [v0.12.2](https://github.com/chef/kitchen-inspec/tree/v0.12.2) (2016-02-22)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.12.1...v0.12.2)

**Fixed bugs:**

- Load directory from single inspec directory [\#54](https://github.com/chef/kitchen-inspec/issues/54)
- update to latest runner interface in inspec [\#56](https://github.com/chef/kitchen-inspec/pull/56) ([chris-rock](https://github.com/chris-rock))

## [v0.12.1](https://github.com/chef/kitchen-inspec/tree/v0.12.1) (2016-02-22)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.12.0...v0.12.1)

**Implemented enhancements:**

- Support inspec dir in the test suite dir [\#55](https://github.com/chef/kitchen-inspec/pull/55) ([alexpop](https://github.com/alexpop))

## [v0.12.0](https://github.com/chef/kitchen-inspec/tree/v0.12.0) (2016-02-19)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.11.1...v0.12.0)

**Implemented enhancements:**

- move integration tests to top-level [\#50](https://github.com/chef/kitchen-inspec/pull/50) ([chris-rock](https://github.com/chris-rock))
- support embedded profiles, leave directory checking to inspec [\#49](https://github.com/chef/kitchen-inspec/pull/49) ([chris-rock](https://github.com/chris-rock))

**Fixed bugs:**

- Point test-kitchen to master in Gemfile [\#48](https://github.com/chef/kitchen-inspec/pull/48) ([jaym](https://github.com/jaym))

**Merged pull requests:**

- require latest inspec version [\#53](https://github.com/chef/kitchen-inspec/pull/53) ([chris-rock](https://github.com/chris-rock))
- 0.12.0 [\#52](https://github.com/chef/kitchen-inspec/pull/52) ([chris-rock](https://github.com/chris-rock))

## [v0.11.1](https://github.com/chef/kitchen-inspec/tree/v0.11.1) (2016-02-15)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.11.0...v0.11.1)

**Implemented enhancements:**

- work well with other testing frameworks in test-kitchen [\#40](https://github.com/chef/kitchen-inspec/pull/40) ([chris-rock](https://github.com/chris-rock))

**Fixed bugs:**

- bugfix: use the right container in combination with kitchen-dokken [\#43](https://github.com/chef/kitchen-inspec/pull/43) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.11.1 [\#47](https://github.com/chef/kitchen-inspec/pull/47) ([chris-rock](https://github.com/chris-rock))
- deduplicate Gemfiles [\#41](https://github.com/chef/kitchen-inspec/pull/41) ([srenatus](https://github.com/srenatus))

## [v0.11.0](https://github.com/chef/kitchen-inspec/tree/v0.11.0) (2016-02-08)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.10.1...v0.11.0)

**Implemented enhancements:**

- Add integration test with test-kitchen [\#33](https://github.com/chef/kitchen-inspec/pull/33) ([chris-rock](https://github.com/chris-rock))

**Closed issues:**

- Failures should be tagged with the instance they failed against [\#30](https://github.com/chef/kitchen-inspec/issues/30)
- kitchen verify has exit status 0 with failed examples [\#9](https://github.com/chef/kitchen-inspec/issues/9)

**Merged pull requests:**

- 0.11.0 [\#38](https://github.com/chef/kitchen-inspec/pull/38) ([chris-rock](https://github.com/chris-rock))

## [v0.10.1](https://github.com/chef/kitchen-inspec/tree/v0.10.1) (2016-01-15)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.10.0...v0.10.1)

**Closed issues:**

- Inspec does not gracefully allow transports other than winrm and ssh. [\#31](https://github.com/chef/kitchen-inspec/issues/31)
- Specify inspec output formats in .kitchen.yml [\#26](https://github.com/chef/kitchen-inspec/issues/26)

**Merged pull requests:**

- 0.10.1 [\#34](https://github.com/chef/kitchen-inspec/pull/34) ([chris-rock](https://github.com/chris-rock))
- Allow transports which are subclasses of the core ones. [\#32](https://github.com/chef/kitchen-inspec/pull/32) ([coderanger](https://github.com/coderanger))

## [v0.10.0](https://github.com/chef/kitchen-inspec/tree/v0.10.0) (2016-01-07)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.9.6...v0.10.0)

**Fixed bugs:**

- kitchen test destroys the instance with failing tests [\#16](https://github.com/chef/kitchen-inspec/issues/16)
- Pending messages are "inherited"/"propagated" down with several suites [\#15](https://github.com/chef/kitchen-inspec/issues/15)

**Merged pull requests:**

- Preparing the 0.10.0 release [\#29](https://github.com/chef/kitchen-inspec/pull/29) ([tyler-ball](https://github.com/tyler-ball))
- Make test-kitchen a dev dependency [\#28](https://github.com/chef/kitchen-inspec/pull/28) ([jaym](https://github.com/jaym))
- Specify inspec output format from kitchen.yml [\#27](https://github.com/chef/kitchen-inspec/pull/27) ([cheesesashimi](https://github.com/cheesesashimi))
- remove gem push restriction [\#24](https://github.com/chef/kitchen-inspec/pull/24) ([arlimus](https://github.com/arlimus))

## [v0.9.6](https://github.com/chef/kitchen-inspec/tree/v0.9.6) (2015-12-11)
[Full Changelog](https://github.com/chef/kitchen-inspec/compare/v0.9.0...v0.9.6)

**Implemented enhancements:**

- add changelog [\#18](https://github.com/chef/kitchen-inspec/pull/18) ([chris-rock](https://github.com/chris-rock))
- support test suite helpers [\#12](https://github.com/chef/kitchen-inspec/pull/12) ([schisamo](https://github.com/schisamo))
- Fix typo in README [\#8](https://github.com/chef/kitchen-inspec/pull/8) ([englishm](https://github.com/englishm))
- Gem [\#7](https://github.com/chef/kitchen-inspec/pull/7) ([chris-rock](https://github.com/chris-rock))

**Fixed bugs:**

- tests fail with inspec 0.9.5 [\#19](https://github.com/chef/kitchen-inspec/issues/19)
- Fix tests and activate linting for CI [\#20](https://github.com/chef/kitchen-inspec/pull/20) ([srenatus](https://github.com/srenatus))
- raise ActionFailed when inspec returns other than 0. [\#13](https://github.com/chef/kitchen-inspec/pull/13) ([sawanoboly](https://github.com/sawanoboly))

**Closed issues:**

- ReadMe 'example here' dead link / 404 [\#21](https://github.com/chef/kitchen-inspec/issues/21)

**Merged pull requests:**

- 0.9.6 [\#23](https://github.com/chef/kitchen-inspec/pull/23) ([arlimus](https://github.com/arlimus))
- fix readme [\#22](https://github.com/chef/kitchen-inspec/pull/22) ([srenatus](https://github.com/srenatus))

## [v0.9.0](https://github.com/chef/kitchen-inspec/tree/v0.9.0) (2015-11-03)
**Implemented enhancements:**

- Update README.md [\#6](https://github.com/chef/kitchen-inspec/pull/6) ([chris-rock](https://github.com/chris-rock))
- Support all Kitchen/SSH as Train/SSH tunables. [\#4](https://github.com/chef/kitchen-inspec/pull/4) ([fnichol](https://github.com/fnichol))
- use new inspec as gem source [\#3](https://github.com/chef/kitchen-inspec/pull/3) ([chris-rock](https://github.com/chris-rock))
- Rename + Update [\#2](https://github.com/chef/kitchen-inspec/pull/2) ([chris-rock](https://github.com/chris-rock))
- add usage instructions [\#1](https://github.com/chef/kitchen-inspec/pull/1) ([chris-rock](https://github.com/chris-rock))

**Fixed bugs:**

- Add WinRM support to Verifier \(pending full support in Train\). [\#5](https://github.com/chef/kitchen-inspec/pull/5) ([fnichol](https://github.com/fnichol))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
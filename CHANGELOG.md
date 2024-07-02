osl-php CHANGELOG
=================
This file is used to list changes made in each version of the
osl-php cookbook.

7.0.0 (2024-07-02)
------------------
- Convert to Resource-Based

6.4.3 (2023-05-22)
------------------
- Helper methods for setting php-fpm servers base on memory

6.4.2 (2023-05-04)
------------------
- Remove CentOS Stream 8

6.4.1 (2023-04-18)
------------------
- Update support for pecl-imagic

6.4.0 (2023-04-17)
------------------
- Added PHP 7.4 to ius archive versions

6.3.0 (2023-02-22)
------------------
- AlmaLinux 8 Support

6.2.1 (2022-09-14)
------------------
- Update to composer 2.2.18

6.2.0 (2022-03-15)
------------------
- Add composer pin to metadata

6.1.0 (2022-01-31)
------------------
- Remove PHP 7.1 and 7.3 support

6.0.0 (2022-01-24)
------------------
- Proper C8 support w/ Remi modules

5.10.2 (2021-09-03)
-------------------
- Set the default timezone to UTC

5.10.1 (2021-08-05)
-------------------
- Allow pecl-imagick for php7.4 on CentOS 7

5.10.0 (2021-06-17)
-------------------
- Migrate to using osl-repos

5.9.0 (2021-06-16)
------------------
- Set unified_mode for custom resources

5.8.1 (2021-04-16)
------------------
- Fix default IUS installation if we don't explictly set node['php']['version']

5.8.0 (2021-04-16)
------------------
- Enable Selinux Enforcing

5.7.0 (2021-04-07)
------------------
- Update Chef dependency to >= 16

5.6.0 (2021-03-08)
------------------
- Update to cookbook use php 8.0

5.5.2 (2021-02-16)
------------------
- Use ius-archive repo for php 7.2

5.5.1 (2020-10-20)
------------------
- Fix disabling ius-archive when switching between versions

5.5.0 (2020-10-07)
------------------
- Remove support for php 5.3 and 7.0

5.4.0 (2020-09-02)
------------------
- updates for 16

5.3.2 (2020-08-19)
------------------
- Update php bash helpers

5.3.1 (2020-07-27)
------------------
- Add phpcheck & phpshow bash aliases

5.3.0 (2020-07-06)
------------------
- Added exclusions for php7.4 packages

5.2.0 (2020-06-22)
------------------
- Chef 15 fixes

5.1.0 (2020-05-01)
------------------
- Workaround for ImageMagick on CentOS 7 with ius-archive

5.0.1 (2020-04-17)
------------------
- Set PHP 7.1 as archived

5.0.0 (2020-02-24)
------------------
- CentOS 8

4.1.0 (2019-12-22)
------------------
- Chef 14 post-migration fixes

4.0.3 (2019-11-18)
------------------
- Allow Composer version to be configured via attribute

4.0.2 (2019-11-14)
------------------
- Add support for PHP 7.3

4.0.1 (2019-10-18)
------------------
- Bump to yum-ius ~> 3.1.0 to pull in upstream fixes

4.0.0 (2019-08-12)
------------------
- Migrate to Chef 14

3.2.1 (2019-05-03)
------------------
- Fix IUS archive not being enabled properly

3.2.0 (2019-03-28)
------------------
- Added Option to Install + Configure Zend Opcache

3.1.2 (2019-03-15)
------------------
- Bring php-5.3 back from the dead

3.1.1 (2019-02-18)
------------------
- Enable IUS Archive repo for PHP 5.6, 7.0

3.1.0 (2019-01-16)
------------------
- Added custom resource for php ini files

3.0.0 (2018-07-17)
------------------
- Chef 13 compatibility fixes

2.0.1 (2018-02-21)
------------------
- Fix issue with pear and php72u

2.0.0 (2018-01-04)
------------------
- Normalize node['osl-php']['packages'] to be agnostic to PHP versions

1.0.0 (2017-10-19)
------------------
- Use php cookbook version 4.5.0.

0.2.1 (2017-09-19)
------------------
- Lock upstream cookbook to what we have in production

0.2.0 (2017-05-19)
------------------
- Include php::ini in packages recipe.

0.1.4 (2017-01-04)
------------------
- Clean up osl-php

0.1.3 (2016-10-24)
------------------
- Create composer cookbook, along with chefspec testing

0.1.0
-----
- Initial release of osl-php


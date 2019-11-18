osl-php CHANGELOG
=================
This file is used to list changes made in each version of the
osl-php cookbook.

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


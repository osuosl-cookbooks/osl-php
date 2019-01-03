name             'php_ini-test'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 12.18' if respond_to?(:chef_version)
issues_url       'https://github.com/osuosl-cookbooks/php_ini-test/issues'
source_url       'https://github.com/osuosl-cookbooks/php_ini-test'
description      'Installs/Configures php_ini-test'
long_description 'Installs/Configures php_ini-test'
version          '0.1.0'

depends          'osl-php'

supports         'centos', '~> 7.0'

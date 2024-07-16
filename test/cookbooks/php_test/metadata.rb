name             'php_test'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 12.18'
issues_url       'https://github.com/osuosl-cookbooks/osl-php/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-php'
description      'Installs/Configures php_test'
version          '0.1.0'

depends          'osl-php'
depends          'apache2'

supports         'almalinux', '~> 8.0'

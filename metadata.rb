name             'osl-php'
maintainer       'Anthony Miller'
maintainer_email 'armiller@osuosl.org'
source_url       'https://github.com/osuosl-cookbooks/osl-php'
issues_url       'https://github.com/osuosl-cookbooks/osl-php/issues'
license          'Apache-2.0'
chef_version     '>= 12.18' if respond_to?(:chef_version)
description      'Installs/Configures osl-php'
long_description 'Installs/Configures osl-php'
version          '3.0.0'

supports         'centos', '~> 6.0'
supports         'centos', '~> 7.0'

depends          'build-essential'
depends          'composer'
depends          'php', '~> 4.5.0'
depends          'yum-ius', '~> 3.0.0'

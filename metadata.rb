name             'osl-php'
maintainer       'Anthony Miller'
maintainer_email 'armiller@osuosl.org'
source_url       'https://github.com/osuosl-cookbooks/osl-php'
issues_url       'https://github.com/osuosl-cookbooks/osl-php/issues'
license          'Apache-2.0'
chef_version     '>= 16.0'
description      'Installs/Configures osl-php'
version          '6.2.1'

supports         'almalinux', '~> 8.0'
supports         'centos', '~> 7.0'
supports         'centos_stream', '~> 8.0'

depends          'composer', '~> 3.0'
depends          'osl-repos'
depends          'osl-selinux'
depends          'php', '~> 9.1.0'
depends          'yum-ius'
depends          'yum-osuosl'
depends          'yum-remi-chef', '>= 6.1.0'

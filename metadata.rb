name             'osl-php'
maintainer       'Anthony Miller'
maintainer_email 'armiller@osuosl.org'
source_url       'https://github.com/osuosl-cookbooks/osl-php'
issues_url       'https://github.com/osuosl-cookbooks/osl-php/issues'
license          'Apache-2.0'
chef_version     '>= 14.0'
description      'Installs/Configures osl-php'
version          '5.1.0'

supports         'centos', '~> 8.0'
supports         'centos', '~> 7.0'

depends          'composer'
depends          'php', '~> 7.1.0'
depends          'yum-centos'
depends          'yum-epel'
depends          'yum-ius', '~> 3.1.0'
depends          'yum-osuosl'

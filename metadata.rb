name             'osl-php'
maintainer       'Anthony Miller'
maintainer_email 'armiller@osuosl.org'
source_url       'https://github.com/osuosl-cookbooks/osl-php'
issues_url       'https://github.com/osuosl-cookbooks/osl-php/issues'
license          'Apache-2.0'
chef_version     '>= 16.0'
description      'Installs/Configures osl-php'
version          '5.9.0'

supports         'centos', '~> 8.0'
supports         'centos', '~> 7.0'

depends          'composer'
depends          'osl-selinux'
depends          'php', '~> 8.0.1'
depends          'yum-centos'
depends          'yum-epel'
depends          'yum-ius', '~> 3.1.0'
depends          'yum-osuosl'

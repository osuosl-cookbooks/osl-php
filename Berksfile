source 'https://supermarket.osuosl.org'
source 'https://supermarket.chef.io'

solver :ruby, :required

cookbook 'osl-apache', '>= 10.3.0'

cookbook 'php_test', path: 'test/cookbooks/php_test'

# TEMPORARY: remove once the osl-repos-upstream-releases chain releases
cookbook 'osl-nrpe', git: 'git@github.com:osuosl-cookbooks/osl-nrpe.git', branch: 'ramereth/nrpe-yum-epel'
cookbook 'osl-repos', git: 'git@github.com:osuosl-cookbooks/osl-repos.git', branch: 'aokial/upstream-update'

metadata

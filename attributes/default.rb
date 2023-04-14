default['osl-php']['packages'] = []
default['osl-php']['php_packages'] = []
default['osl-php']['use_ius'] = false
default['osl-php']['use_opcache'] = false
# List PHP versions that require IUS archive repo: https://ius.io/LifeCycle/#php
default['osl-php']['ius_archive_versions'] = %w(5.6 7.1 7.2 7.4)
default['osl-php']['composer_version'] = '2.2.18'

# defaults from php72u-opcache package on Centos 7
default['osl-php']['opcache']['opcache.blacklist_filename'] = '/etc/php.d/opcache*.blacklist'
default['osl-php']['opcache']['opcache.enable'] = 1
default['osl-php']['opcache']['opcache.huge_code_pages'] = 0
default['osl-php']['opcache']['opcache.interned_strings_buffer'] = 8
default['osl-php']['opcache']['opcache.max_accelerated_files'] = 4000
default['osl-php']['opcache']['opcache.memory_consumption'] = 128

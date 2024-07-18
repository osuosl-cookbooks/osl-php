options = {
  'opcache.enable_cli': true,
  'opcache.memory_consumption': 1024,
  'opcache.max_accelerated_files': 1000,
}
osl_php_install 'packages' do
  php_packages node['php_test']['php_packages']
  use_opcache node['php_test']['use_opcache']
  opcache_conf options
  version node['php_test']['version']
end

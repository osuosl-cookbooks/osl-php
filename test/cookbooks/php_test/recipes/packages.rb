osl_php_install 'packages' do
  php_packages node['php_test']['php_packages']
  use_ius node['php_test']['use_ius']
  use_opcache node['php_test']['use_opcache']
  opcache_conf node['php_test']['opcache_conf']
  version node['php_test']['version']
end

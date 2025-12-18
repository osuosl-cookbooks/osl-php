osl_php_install 'system php packages' do
  php_packages %w(devel fpm gd)
end

osl_php_install "remi safe packages #{node['php_test']['version1']}" do
  remi_packages true
  version node['php_test']['version1']
  php_packages node['php_test']['php_packages1']
end

osl_php_install "remi safe packages #{node['php_test']['version2']}" do
  remi_packages true
  version node['php_test']['version2']
  php_packages node['php_test']['php_packages2']
end


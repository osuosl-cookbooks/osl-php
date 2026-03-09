osl_php_install 'system php packages' do
  php_packages %w(devel fpm gd)
end

osl_php_install 'remi safe packages' do
  versioned_packages true
  version node['php_test']['version']
  php_packages node['php_test']['php_packages']
end

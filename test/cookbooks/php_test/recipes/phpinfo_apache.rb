major_version = node['php']['version'].to_i
node.normal['apache']['mod_php']['module_name'] = "php#{major_version}"
node.normal['apache']['mod_php']['so_filename'] = "libphp#{major_version}.so"

include_recipe 'apache2'
include_recipe 'apache2::mod_php'

apache_conf 'localhost' do
  source 'opcache_vhost.erb'
  cookbook 'php_test'
end

apache_site 'localhost'

directory '/var/www/localhost' do
  owner 'apache'
  group 'apache'
end

file '/var/www/localhost/index.php' do
  content <<-EOF
<?php
  phpinfo();
?>
EOF
  owner 'apache'
  group 'apache'
end

service 'httpd' do
  action [:start, :restart]
end

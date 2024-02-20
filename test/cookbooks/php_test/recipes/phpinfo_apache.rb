apache2_install 'default'

major_version =
  if node['php_test']['system_php']
    node['platform_version'].to_i == 7 ? '5' : '7'
  elsif node['php_test']['version'].to_i < 8
    # PHP 8 in Remi does not have version in filename
    node['php_test']['version'].to_i
  end

apache2_module "php#{major_version}" do
  mod_name "libphp#{major_version}.so"
end

apache2_conf 'opcache_vhost' do
  template_cookbook 'php_test'
end

apache2_site 'localhost'

directory '/var/www/localhost' do
  owner 'apache'
  group 'apache'
end

file '/var/www/localhost/index.php' do
  content <<~EOF
    <?php
      phpinfo();
    ?>
  EOF
  owner 'apache'
  group 'apache'
end

apache2_service 'default' do
  action [:enable, :start]
  subscribes :restart, 'apache2_install[default]'
  subscribes :reload, "apache2_module[php#{major_version}]"
  subscribes :reload, 'apache2_conf[opcache_vhost]'
  subscribes :reload, 'apache2_site[localhost]'
end

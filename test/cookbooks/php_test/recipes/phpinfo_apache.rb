apache2_install 'default'

system_php = node['php_test']['version'].nil?
major_version =
  if system_php
    if node['platform_version'].to_i >= 8
      '7'
    else
      node['php_test']['use_ius'] ? '7' : '5'
    end
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
  subscribes :restart, "apache2_module[php#{major_version}]"
  subscribes :restart, 'apache2_conf[opcache_vhost]'
  subscribes :restart, 'apache2_site[localhost]'
end

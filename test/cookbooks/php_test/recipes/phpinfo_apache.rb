system_php = node['php_test']['version'].nil?
major_version =
  if system_php
    if node['platform_version'].to_i >= 9
      8
    else
      7
    end
  elsif node['php_test']['version'].to_i < 8
    # PHP 8 in Remi does not have version in filename
    node['php_test']['version'].to_i
  end

directory '/var/www/php_test' do
  owner 'apache'
  group 'apache'
end

file '/var/www/php_test/index.php' do
  content <<~EOF
    <?php
      phpinfo();
    ?>
  EOF
  owner 'apache'
  group 'apache'
end

if node['platform_version'].to_i >= 9 && system_php
  node.default['osl-apache']['behind_loadbalancer'] = true

  include_recipe 'osl-apache'
  include_recipe 'osl-apache::mod_remoteip'

  %w(proxy proxy_fcgi).each do |m|
    apache2_module m do
      notifies :reload, 'apache2_service[osuosl]'
    end
  end

  php_fpm_pool 'php_test' do
    listen '/var/run/php_test-fpm.sock'
  end

  apache_app 'php_test' do
    directory '/var/www/php_test'
    allow_override 'All'
    directory_options %w(FollowSymLinks MultiViews)
    directive_http [
      '<FilesMatch "\.(php|phar)$">',
      '  SetHandler "proxy:unix:/var/run/php_test-fpm.sock|fcgi://localhost/"',
      '</FilesMatch>',
    ]
    directory_custom_directives [
      'Require all granted',
    ]
  end
else
  apache2_install 'default'

  apache2_module "php#{major_version}" do
    mod_name "libphp#{major_version}.so"
  end

  apache2_conf 'opcache_vhost' do
    template_cookbook 'php_test'
  end

  apache2_site 'php_test'

  apache2_service 'default' do
    action [:enable, :start]
    subscribes :restart, 'apache2_install[default]'
    subscribes :restart, "apache2_module[php#{major_version}]"
    subscribes :restart, 'apache2_conf[opcache_vhost]'
    subscribes :restart, 'apache2_site[php_test]'
  end
end

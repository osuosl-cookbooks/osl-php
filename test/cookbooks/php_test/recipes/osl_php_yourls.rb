include_recipe 'osl-apache'

# package 'php-mysqlnd'

osl_php_install 'osl_php_yourls' do
  version '8.4'
  notifies :reload, 'service[php-fpm]'
end

%w(proxy proxy_fcgi).each do |m|
    apache2_module m do
      notifies :reload, 'apache2_service[osuosl]'
    end
  end


fpm_settings = osl_php_fpm_settings(52)

php_fpm_pool 'yourls' do
  listen '/var/run/yourls-fpm.sock'
  max_children fpm_settings['max_children']
  start_servers fpm_settings['start_servers']
  min_spare_servers fpm_settings['min_spare_servers']
  max_spare_servers fpm_settings['max_spare_servers']
end

service 'php-fpm' do
  action :nothing
end


yourls_webroot = '/var/www/yourls.example.com/yourls'

osl_mysql_test 'yourls' do
  username 'yourls_owner'
  password 'yourls_password'
end

osl_php_yourls 'yourls.example.com' do
  version '1.10'
  db_username 'yourls_owner'
  db_password 'yourls_password'
  db_name 'yourls'
  db_host 'localhost'
  domain 'https://yourls.example.com'
  user_passwords [
    'admin' => 'adminpassword'
  ]
  cookiekey '0h4U_DP&fGgxUFOD-044UZma_W8n)DVTs1B)gbx-'
end


apache_app 'yourls.example.com' do
  directory yourls_webroot
  allow_override 'All'
  directive_http [
    '<FilesMatch "\.(php|phar)$">',
    '  SetHandler "proxy:unix:/var/run/yourls-fpm.sock|fcgi://localhost/"',
    '</FilesMatch>',
  ]
end

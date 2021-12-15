::Chef::Resource.include Apache2::Cookbook::Helpers

# These aren't accessible outside of the apache cookbook, so declare them here for use in this cookbook
service 'apache2' do
  service_name lazy { apache_platform_service_name }
  supports restart: true, status: true, reload: true
  action :nothing
end

apache2_install 'default'

major_version = if system_php?
                  node['platform_version'].to_i == 7 ? '5' : '7'
                else
                  # PHP 8 in Remi does not have version in filename
                  node['php']['version'].to_i if node['php']['version'].to_i < 8
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

resource_name :php_ini

default_action :add

property :mode, String, default: '0644'
property :options, Hash, default: {}, required: true

action :add do
  directory '/etc/php.d'

  template "/etc/php.d/#{new_resource.name}" do
    source 'php_ini.erb'
    cookbook 'osl-php'
    variables data: new_resource.options
    mode new_resource.mode
  end
end

action :remove do
  file "/etc/php.d/#{new_resource.name}" do
    action :delete
  end
end

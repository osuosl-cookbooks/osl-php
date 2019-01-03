resource_name :php_ini

default_action :create

property :mode, String, default: '0644'
property :options, Hash, default: {}, required: true
property :path, String, name_property: true

action :create do
  template new_resource.path do
    source 'php_ini.erb'
    cookbook 'osl-php'
    variables data: new_resource.options
    mode new_resource.mode
  end
end

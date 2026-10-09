resource_name :osl_php_ini
provides :osl_php_ini
unified_mode true

default_action :add

property :mode, String, default: '0644'
property :options, Hash, required: [:add]
property :php_version, String
property :config_dir, String

action :add do
  config_dir = new_resource.config_dir || osl_php_ini_config_dir(new_resource.php_version)
  restart_group = osl_php_restart_group

  directory "#{config_dir} #{new_resource.name}" do
    path config_dir
    recursive true
  end

  template "#{config_dir}/#{new_resource.name}.ini" do
    source 'php_ini.erb'
    cookbook 'osl-php'
    variables data: new_resource.options
    mode new_resource.mode
    notifies :run, restart_group, :delayed
  end
end

action :remove do
  config_dir = new_resource.config_dir || osl_php_ini_config_dir(new_resource.php_version)
  restart_group = osl_php_restart_group

  file "#{config_dir}/#{new_resource.name}.ini" do
    action :delete
    notifies :run, restart_group, :delayed
  end
end

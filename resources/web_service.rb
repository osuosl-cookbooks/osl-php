resource_name :osl_php_web_service
provides :osl_php_web_service
default_action :create
unified_mode true

property :unit, String,
         name_property: true,
         callbacks: { 'must be a systemd unit name without .service' => ->(u) { u.match?(/\A[\w@.-]+\z/) && !u.end_with?('.service') } }

action :create do
  php_service = osl_php_web_service_register(new_resource.unit)

  # The environment only applies when the unit starts, so a changed drop-in needs a restart, not a reload
  osl_systemd_unit_drop_in "php-web-ini #{new_resource.unit}.service" do
    override_name 'php-web-ini'
    unit_name "#{new_resource.unit}.service"
    content('Service' => { 'Environment' => osl_php_web_ini_environment })
    notifies :restart, php_service, :delayed
  end
end

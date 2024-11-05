resource_name :osl_php_install
provides :osl_php_install
unified_mode true

property :composer_version, String, default: lazy { osl_php_default_composer_version }
property :directives, Hash, default: {}
property :opcache_conf, Hash, default: {}
property :packages, Array, default: []
property :php_packages, Array, default: []
property :use_composer, [true, false], default: false
property :use_opcache, [true, false], default: false
property :version, String

action :install do
  system_php = new_resource.version.nil?
  version = new_resource.version || php_version
  shortver = version.delete('.') # version X.X -> XX
  all_packages = new_resource.packages
  all_php_packages = new_resource.php_packages

  include_recipe 'osl-selinux'
  include_recipe 'osl-repos::epel'

  prefix = 'php'

  # opcache
  if new_resource.use_opcache
    osl_php_ini '10-opcache' do
      options osl_php_opcache_conf.merge!(new_resource.opcache_conf)
    end
  end

  unless system_php
    # enable powertools repo for libedit-devel
    include_recipe 'osl-repos::alma'

    # use Remi PHP module to override stock php
    # programatically define resource as to not have a bit long case/when
    declare_resource(:"yum_remi_php#{shortver}", 'default')
  end

  # install default packages if no packages were specified, but wait to select the mod_php and pear packages
  if all_packages.empty? && all_php_packages.empty?
    all_php_packages = osl_php_default_installation_packages_without_prefixes
  end

  all_packages += all_php_packages.map { |p| "#{prefix}-#{p}" }

  # add the mod_php package, which is just 'php'
  all_packages <<= prefix

  if new_resource.use_opcache
    all_packages <<= "#{prefix}-opcache"
  end

  php_install "#{new_resource.name} all packages" do
    packages all_packages
    directives new_resource.directives
  end

  pear_pkg = "#{prefix}-pear"

  package 'pear' do
    package_name pear_pkg
  end unless all_packages.any? { |p| /pear/ =~ p }

  osl_php_ini 'timezone' do
    options('date.timezone' => 'UTC')
  end

  %w(phpcheck phpshow).each do |file|
    cookbook_file "/usr/local/bin/#{file}" do
      source file
      mode '755'
      cookbook 'osl-php'
    end
  end

  if new_resource.use_composer
    composer_url = "https://getcomposer.org/download/#{new_resource.composer_version}/composer.phar"

    remote_file '/usr/local/bin/composer' do
      source composer_url
      mode '755'
      action :create_if_missing
    end
  end

  directory '/etc/httpd/conf.modules.d' do
    recursive true
    action :delete
  end
end

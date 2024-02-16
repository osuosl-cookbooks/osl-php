resource_name :osl_php_apc
provides :osl_php_apc
unified_mode true

property :options, Hash, default: lazy { apc_conf }

action :install do
  ruby_block 'raise_el8_exception' do
    block do
      raise 'APC is not compatible with EL 8.'
    end
    only_if { node['platform_version'].to_i >= 8 }
  end

  # include_recipe 'osl-selinux'
  selinux_install 'osl-selinux'
  selinux_state 'osl-selinux' do
    action :enforcing
  end

  %w(httpd-devel pcre pcre-devel).each do |pkg|
    package pkg do
      action :install
    end
  end

  build_essential 'APC'

  php_pear 'APC' do
    action :install
    # Use channel 'pecl' since APC is not available on the default channel
    channel 'pecl'
  end

  osl_php_ini 'APC' do
    action :add
    options new_resource.options
  end
end

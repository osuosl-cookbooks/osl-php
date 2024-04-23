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

  include_recipe 'osl-selinux'

  package %w(httpd-devel pcre pcre-devel)

  # build_essential 'APC'  <-- the php_pear resource does this already

  php_pear 'APC' do
    action :install
    # Use channel 'pecl' since APC is not available on the default channel
    channel 'pecl.php.net'
  end

  osl_php_ini 'APC' do
    options new_resource.options
  end
end

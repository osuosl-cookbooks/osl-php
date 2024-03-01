resource_name :osl_php_install
provides :osl_php_install
unified_mode true

property :packages, Array, default: []
property :php_packages, Array, default: []
property :use_ius, [true, false], default: false
property :version, String
property :use_composer, [true, false], default: false
property :composer_version, String
property :use_opcache, [true, false], default: false
property :opcache_conf, Hash, default: lazy {}

action :install do
  system_php = new_resource.version.nil?
  version = new_resource.version.nil? ? php_version : new_resource.version
  shortver = version.delete('.') # version X.X -> XX
  all_packages = new_resource.packages.to_a
  all_php_packages = new_resource.php_packages.to_a

  # To avoid warnings about including recipes in a resource, do the same things these recipes do ---
  # include_recipe 'osl-selinux'
  selinux_install 'osl-selinux'
  selinux_state 'osl-selinux' do
    action :enforcing
  end

  # include_recipe 'osl-repos::epel'
  osl_repos_epel 'default'
  #---

  prefix = 'php'

  # opcache
  if new_resource.use_opcache
    if version.to_f < 5.5 || !new_resource.use_ius
      raise 'Must use PHP >= 5.5 with ius enabled to use Zend Opcache.'
    end

    all_php_packages <<= 'opcache'

    osl_php_ini '10-opcache' do
      options opcache_conf.merge!(new_resource.opcache_conf)
    end
  end
  # ---

  # include_recipe 'osl-php::packages' -------------------------------------------------------------------------------

  # === use IUS repo on EL7 ===
  if node['platform_version'].to_i == 7 && new_resource.use_ius
    # default to 7.4 if version not explicitly set
    if system_php
      system_php = false
      version = '7.4'
    end

    # Enable IUS archive repo for archived versions
    enable_ius_archive = ius_archive_versions.include?(version)
    node.default['yum']['ius-archive']['enabled'] = enable_ius_archive
    node.default['yum']['ius-archive']['managed'] = true

    # include_recipe 'osl-repos::centos'
    osl_repos_centos 'default' do
      exclude 'ImageMagick*' if enable_ius_archive && version.to_f <= 7.1
    end

    # include_recipe 'yum-osuosl'
    yum_repository 'osuosl' do
      repositoryid 'osuosl'
      description 'OSUOSL repo $releasever - $basearch'
      baseurl 'http://ftp.osuosl.org/pub/osl/repos/yum/$releasever/$basearch'
      gpgkey 'http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
      action :create
    end

    include_recipe 'yum-ius'

    case version
    when '7.2'
      r_a = resources(yum_repository: 'ius-archive')
      r_a.exclude = [r_a.exclude, 'php5* php71* php73* php74*'].compact.join(' ')
      r = resources(yum_repository: 'ius')
      r.exclude = [r.exclude, 'php73* php74*'].compact.join(' ')
    end

    # IUS has php versions as php72u-foo or php73-foo
    prefix = "php#{shortver}#{'u' if version.to_f < 7.3}"
  end

  # === use Remi dnf modules on EL8 ===
  if node['platform_version'] >= 8 && !system_php
    # enable powertools repo for libedit-devel
    osl_repos_centos 'default' if platform?('centos')
    osl_repos_alma 'default' if platform?('almalinux')

    # use Remi PHP module to override stock php
    # programatically define resource as to not have a bit long case/when
    declare_resource(:"yum_remi_php#{shortver}", 'default')
  end

  all_packages += all_php_packages.map { |p| "#{prefix}-#{p}" }

  # pecl-imagick is not available on EL8
  all_packages.delete_if { |p| p.match? /pecl-imagick/ } if node['platform_version'].to_i >= 8 && system_php

  # add the mod_php package, which is 'mod_php' in IUS or just 'php' otherwise
  # TODO: original logic checks if `packages` is empty first - check if that's necessary here
  if all_packages.any?
    all_packages <<= if node['platform_version'].to_i == 7 && version.to_i >= 7 && !system_php
                       # When installing the main PHP (>= 7.0) package directly, like
                       # php72u, it's actually installing the mod_php package, so we
                       # explicitly do that here.
                       "mod_#{prefix}"
                     else
                       prefix
                     end
  end

  php_install 'all-packages' do
    packages all_packages.empty? ? php_installation_packages : all_packages
  end

  # Include pear package (pear1 for PHP 7.1+ on C7)
  pear_pkg = if !system_php && version.to_f >= 7.1 && node['platform_version'].to_i == 7
               'pear1'
             else
               "#{prefix}-pear"
             end

  # TODO: use pear resource?
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
end

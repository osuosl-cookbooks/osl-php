#
# Cookbook:: osl-php
# Recipe:: default
#
# Copyright:: 2013-2023, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
resource_name :osl_php_install
provides :osl_php_install
unified_mode true

property :packages, [Array], default: lazy { php_installation_packages }
property :php_packages, [Array, nil]
property :use_ius, [true, false], default: false
property :version, String, default: lazy { php_version }
property :use_opcache, [true, false], default: false
property :use_remi, [true, false], default: false
property :opcache_conf, Hash, default: lazy { opcache_conf }

action :install do
  # To avoid warnings about including recipes in a resource, do the same things these recipes do ---
  # include_recipe 'osl-selinux'
  selinux_install 'osl-selinux'
  selinux_state 'osl-selinux' do
    action :enforcing
  end

  # include_recipe 'osl-repos::epel'
  osl_repos_epel 'default'
  #---

  all_packages = new_resource.packages
  execute "echo #{all_packages}" do
    live_stream true
  end
  prefix = 'php'

  if new_resource.use_opcache
    if new_resource.version.to_f < 5.5 || !new_resource.use_opcache
      raise 'Must use PHP >= 5.5 with ius enabled to use Zend Opcache.'
    end

    all_packages << 'opcache'

    osl_php_ini '10-opcache' do
      options new_resource.opcache_conf
    end
  end

  # include_recipe 'osl-php::packages' ----------------------------------------------------

  shortver = new_resource.version.delete('.') # version X.X -> XX

  # === use IUS repo on EL7 ===
  if node['platform_version'].to_i == 7 && new_resource.use_ius
    # Enable IUS archive repo for archived versions
    enable_ius_archive = ius_archive_versions.any? { |v| new_resource.version == v }
    node.default['yum']['ius-archive']['enabled'] = enable_ius_archive
    node.default['yum']['ius-archive']['managed'] = true

    include_recipe 'osl-repos::centos'
    include_recipe 'yum-osuosl'

    # CentOS 7.8 updated ImageMagick which broke installations from ius-archive for php versions 7.1 and below
    if enable_ius_archive && node['platform_version'].to_i >= 7 && new_resource.version <= 7.1
      # This is an annoying workaround since the resource doesn't show up properly using the osl_repos_centos resource. We
      # don't include this in metadata as it will mess up ordering but gets pulled in automatically with osl-repos
      include_recipe 'yum-centos'

      # Exclude all ImageMagick packages from the CentOS repos
      node['yum-centos']['repos'].each do |repo|
        next unless node['yum'][repo]['managed']
        r = resources(yum_repository: repo)
        # If we already have excludes, include them and append ImageMagick
        r.exclude = [r.exclude, 'ImageMagick*'].flatten.compact.join(' ')
      end
    end

    include_recipe 'yum-ius'

    case new_resource.version
    when 7.2
      r_a = resources(yum_repository: 'ius-archive')
      r_a.exclude = [r_a.exclude, 'php5* php71* php73* php74*'].compact.join(' ')
      r = resources(yum_repository: 'ius')
      r.exclude = [r.exclude, 'php73* php74*'].compact.join(' ')
    end

    # IUS has php versions as php72u-foo or php73-foo
    prefix = "php#{shortver}#{'u' if new_resource.version < 7.3}"
  end

  # === use REMI dnf modules on EL8 ===
  if node['platform_version'] >= 8 && new_resource.use_remi
    # enable powertools repo for libedit-devel
    osl_repos_centos 'default' if platform?('centos')
    osl_repos_alma 'default' if platform?('almalinux')

    # use remi PHP module to override stock php
    # programatically define resource as to not have a bit long case/when
    declare_resource(:"yum_remi_php#{shortver}", 'default')
  end

  all_packages |= new_resource.php_packages.map { |p| "#{prefix}-#{p}" } unless new_resource.php_packages.nil?

  # pecl-imagick is not available on EL 8
  all_packages.delete_if { |p| p.match? /pecl-imagick/ } if node['platform_version'].to_i >= 8 &&
                                                            !new_resource.use_remi &&
                                                            !new_resource.use_ius

  # add the mod_php package, which is 'mod_php' in IUS or just 'php' otherwise
  all_packages |= if node['platform_version'].to_i == 7 && new_resource.version.to_i >= 7
                    # When installing the main PHP (>= 7.0) package directly, like
                    # php72u, it's actually installing the mod_php package, so we
                    # explicitly do that here.
                    ["mod_#{prefix}"]
                  else
                    [prefix]
                  end

  execute "echo #{all_packages}" do
    live_stream true
  end

  php_install 'all-packages' do
    packages all_packages
  end

  # Include pear package (pear1 for PHP 7.1+ on C7)
  pear_pkg = if new_resource.version.to_f >= 7.1 && node['platform_version'].to_i == 7
               ['pear1']
             else
               ["#{prefix}-pear"]
             end

  # TODO: use pear resource?
  package 'pear' do
    package_name pear_pkg
  end

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
end

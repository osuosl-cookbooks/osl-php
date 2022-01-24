#
# Cookbook:: osl-php
# Recipe:: packages
#
# Copyright:: 2014-2022, Oregon State University
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

include_recipe 'osl-selinux'

version = node['php']['version']
shortver = version.delete('.')
packages = node['osl-php']['packages'].flatten
prefix = 'php'

# === use IUS repo on C7 ===
if node['platform_version'].to_i == 7 && node['osl-php']['use_ius']
  # default to 7.4 if version not explicitly set
  version = node.default['php']['version'] = '7.4' if system_php?
  shortver = version.delete('.')

  # Enable IUS archive repo for archived versions
  enable_ius_archive = node['osl-php']['ius_archive_versions'].any? { |v| version.start_with?(v) }
  node.default['yum']['ius-archive']['enabled'] = enable_ius_archive
  node.default['yum']['ius-archive']['managed'] = true

  include_recipe 'osl-repos::centos'
  include_recipe 'yum-osuosl'

  # CentOS 7.8 updated ImageMagick which broke installations from ius-archive for php versions 7.1 and below
  if enable_ius_archive && node['platform_version'].to_i >= 7 && version.to_f <= 7.1
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

  case version.to_f
  when 7.1
    r_a = resources(yum_repository: 'ius-archive')
    r_a.exclude = [r_a.exclude, 'php5* php72* php73* php74*'].compact.join(' ')
    r = resources(yum_repository: 'ius')
    r.exclude = [r.exclude, 'php72* php73* php74*'].compact.join(' ')
  when 7.2
    r_a = resources(yum_repository: 'ius-archive')
    r_a.exclude = [r_a.exclude, 'php5* php71* php73* php74*'].compact.join(' ')
    r = resources(yum_repository: 'ius')
    r.exclude = [r.exclude, 'php73* php74*'].compact.join(' ')
  when 7.3
    r = resources(yum_repository: 'ius')
    r.exclude = [r.exclude, 'php74*'].compact.join(' ')
  end

  # IUS has php versions as php72u-foo or php73-foo
  prefix = "php#{shortver}#{'u' if version.to_f < 7.3}"
end

# === use REMI dnf modules on C8 ===
if node['platform_version'] >= 8 && !system_php?
  osl_repos_centos 'default' # enable powertools repo for libedit-devel

  # use remi PHP module to override stock php
  # programatically define resource as to not have a bit long case/when
  declare_resource(:"yum_remi_php#{shortver}", 'default')
end

packages += node['osl-php']['php_packages'].map { |p| "#{prefix}-#{p}" }

# pecl-imagick is not available on CentOS 8
packages.delete_if { |p| p.match? /pecl-imagick/ } if node['platform_version'].to_i >= 8

# If any of our attributes are set, modify upstream packages attribute
if packages.any?
  # add the mod_php package, which is 'mod_php' in IUS or just 'php' otherwise
  packages <<= if node['platform_version'].to_i == 7 && version.to_i >= 7 && !system_php?
                 # When installing the main PHP (>= 7.0) package directly, like
                 # php72u, it's actually installing the mod_php package, so we
                 # explicitly do that here.
                 "mod_#{prefix}"
               else
                 prefix
               end

  node.default['php']['packages'] = packages
end

include_recipe 'php::package'

# Include pear package (pear1 for PHP 7.1+ on C7)
pear_pkg = if !system_php? && version.to_f >= 7.1 && node['platform_version'].to_i == 7
             'pear1'
           else
             prefix + '-pear'
           end

package 'pear' do
  package_name pear_pkg
end

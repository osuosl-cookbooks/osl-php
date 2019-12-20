#
# Cookbook Name:: osl-php
# Recipe:: packages
#
# Copyright 2014, Oregon State University
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

if node['osl-php']['use_ius'] && node['platform_version'].to_i < 8
  # Enable IUS archive repo for archived versions
  enable_ius_archive = node['osl-php']['ius_archive_versions'].any? { |v| node['php']['version'].start_with?(v) }
  node.default['yum']['ius-archive']['enabled'] = enable_ius_archive
  node.default['yum']['ius-archive']['managed'] = enable_ius_archive

  # php53u RPMs built against CentOS 7
  if node['php']['version'].to_f == 5.3 && node['platform_version'].to_i >= 7
    node.default['yum']['ius']['gpgkey'] = 'http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
    node.default['yum']['ius']['baseurl'] = 'http://ftp.osuosl.org/pub/osl/repos/yum/$releasever/php53/$basearch'
    node.default['yum']['ius']['mirrorlist'] = nil
  end

  include_recipe 'yum-ius'

  case node['php']['version'].to_f
  when 7.1
    r = resources(yum_repository: 'ius')
    r.exclude = [r.exclude, 'php72* php73*'].reject(&:nil?).join(' ')
  when 7.2
    r = resources(yum_repository: 'ius')
    r.exclude = [r.exclude, 'php73*'].reject(&:nil?).join(' ')
  end
elsif node['osl-php']['use_ius'] && node['platform_version'].to_i >= 8
  Chef::Log.warn("Use of node['osl-php']['use_ius'] is ignored on CentOS 8 as there is no support for it upstream")
end

version = node['php']['version']

# Get package prefix from version (e.g. "php71u" or "php")
prefix = if node['osl-php']['use_ius'] && node['platform_version'].to_i < 8
           # The IUS repo removed the 'u' at the end of the prefix with PHP 7.3 packages.
           'php' + version.split('.')[0, 2].join + (version.to_f < 7.3 ? 'u' : '')
         else
           'php'
         end

packages = []
packages += node['osl-php']['packages'].flatten

# Prepend PHP package prefix to short packages (e.g. "php71u-memcached")
if node['osl-php']['php_packages'].any?
  packages += node['osl-php']['php_packages'].map { |pkg| prefix + '-' + pkg }
end

# If any of our attributes are set, modify upstream packages attribute
if packages.any? || node['osl-php']['use_ius']
  packages <<= if version.to_f < 7
                 prefix
               elsif node['platform_version'].to_i >= 8
                 'php'
               else
                 # When installing the main PHP (>= 7.0) package directly, like
                 # php72u, it's actually installing the mod_php package, so we
                 # explicitly do that here.
                 "mod_#{prefix}"
               end

  # Include pear package (pear1 for PHP 7.1+)
  pear_pkg =
    if node['platform_version'].to_i >= 8
      'php-pear'
    elsif version.to_f >= 7.1
      'pear1'
    else
      prefix + '-pear'
    end
  package 'pear' do
    package_name pear_pkg
  end

  node.default['php']['packages'] = packages
end

include_recipe 'php::package'

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

if node['osl-php']['use_ius']
  # Enable IUS archive repo for archived versions
  enable_ius_archive = node['osl-php']['ius_archive_versions'].include?(node['php']['version'])
  node.default['yum']['ius-archive']['enabled'] = enable_ius_archive
  node.default['yum']['ius-archive']['managed'] = enable_ius_archive

  include_recipe 'yum-ius'

  if node['php']['version'].to_f == 7.1
    r = resources(yum_repository: 'ius')
    r.exclude = [r.exclude, 'php72*'].reject(&:nil?).join(' ')
  end
end

version = node['php']['version']

# Get package prefix from version (e.g. "php71u" or "php")
prefix = if node['osl-php']['use_ius']
           'php' + version.split('.')[0, 2].join + 'u'
         else
           'php'
         end

packages = []
packages += node['osl-php']['packages']

# Prepend PHP package prefix to short packages (e.g. "php71u-memcached")
if node['osl-php']['php_packages'].any?
  packages += node['osl-php']['php_packages'].map { |pkg| prefix + '-' + pkg }
end

# If any of our attributes are set, modify upstream packages attribute
if packages.any? || node['osl-php']['use_ius']
  packages <<= prefix # Prefix is also the name of the main PHP package

  # Include pear package (pear1u for PHP 7.1+)
  package 'pear' do
    package_name version.to_f >= 7.1 ? 'pear1u' : prefix + '-pear'
  end

  node.default['php']['packages'] = packages
end

include_recipe 'php::package'

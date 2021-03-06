#
# Cookbook:: osl-php
# Recipe:: packages
#
# Copyright:: 2014-2021, Oregon State University
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

if node['osl-php']['use_ius'] && node['platform_version'].to_i < 8
  # Enable IUS archive repo for archived versions
  unless system_php?
    enable_ius_archive = node['osl-php']['ius_archive_versions'].any? { |v| node['php']['version'].start_with?(v) }
    node.default['yum']['ius-archive']['enabled'] = enable_ius_archive
    node.default['yum']['ius-archive']['managed'] = true
  end

  include_recipe 'osl-repos::centos'
  include_recipe 'yum-osuosl'

  # CentOS 7.8 updated ImageMagick which broke installations from ius-archive for php versions 7.1 and below
  if enable_ius_archive && node['platform_version'].to_i >= 7 && node['php']['version'].to_f <= 7.1
    # This is an annoying workaround since the resource doesn't show up properly using the osl_repos_centos resource. We
    # don't include this in metadata as it will mess up ordering but gets pulled in automatically with osl-repos
    include_recipe 'yum-centos'

    # Exclude all ImageMagick packages from the CentOS repos
    node['yum-centos']['repos'].each do |repo|
      next unless node['yum'][repo]['managed']
      r = resources(yum_repository: repo)
      # If we already have excludes, include them and append ImageMagick
      r.exclude = [r.exclude, 'ImageMagick*'].reject(&:nil?).join(' ')
    end
  end

  include_recipe 'yum-ius'

  unless system_php?
    case node['php']['version'].to_f
    when 7.1
      r_a = resources(yum_repository: 'ius-archive')
      r_a.exclude = [r_a.exclude, 'php5* php72* php73* php74*'].reject(&:nil?).join(' ')
      r = resources(yum_repository: 'ius')
      r.exclude = [r.exclude, 'php72* php73* php74*'].reject(&:nil?).join(' ')
    when 7.2
      r_a = resources(yum_repository: 'ius-archive')
      r_a.exclude = [r_a.exclude, 'php5* php71* php73* php74*'].reject(&:nil?).join(' ')
      r = resources(yum_repository: 'ius')
      r.exclude = [r.exclude, 'php73* php74*'].reject(&:nil?).join(' ')
    when 7.3
      r = resources(yum_repository: 'ius')
      r.exclude = [r.exclude, 'php74*'].reject(&:nil?).join(' ')
    end
  end
elsif node['osl-php']['use_ius'] && node['platform_version'].to_i >= 8
  Chef::Log.warn("Use of node['osl-php']['use_ius'] is ignored on CentOS 8 as there is no support for it upstream")
end

version = node['php']['version']

# Get package prefix from version (e.g. "php73u" or "php")
prefix = if node['osl-php']['use_ius'] && system_php? && node['platform_version'].to_i < 8
           # Let's default to php74 if no version is set when using IUS
           'php74'
         elsif node['osl-php']['use_ius'] && node['platform_version'].to_i < 8
           # The IUS repo removed the 'u' at the end of the prefix with PHP 7.3 packages.
           'php' + version.split('.')[0, 2].join + (version.to_f < 7.3 ? 'u' : '')
         else
           'php'
         end

packages = []
packages += node['osl-php']['packages'].flatten

# Prepend PHP package prefix to short packages (e.g. "php71u-memcached")
if node['osl-php']['php_packages'].any?
  osl_packages = []
  osl_packages = osl_packages.concat(node['osl-php']['php_packages'])
  # pecl-imagick is not available for php7.4 or CentOS 8
  if (node['platform_version'].to_i >= 8 || prefix == 'php74') && osl_packages.include?('pecl-imagick')
    osl_packages.delete_if { |pkg| pkg == 'pecl-imagick' }
  end
  packages += osl_packages.map { |pkg| prefix + '-' + pkg }
end

# If any of our attributes are set, modify upstream packages attribute
if packages.any? || node['osl-php']['use_ius']
  packages <<= if (system_php? && !node['osl-php']['use_ius']) || version.to_f < 7
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
    if (system_php? && !node['osl-php']['use_ius']) || node['platform_version'].to_i >= 8
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

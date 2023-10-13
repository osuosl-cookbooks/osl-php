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

property :packages, default: php_packages
property :version, default: php_version
property :use_ius, [true, false], default: false
property :use_opcache, [true, false], default: false
property :opcache_conf, Hash, default: osl-php_opcache_conf

include_recipe 'osl-selinux'
include_recipe 'osl-repos::epel'

if new_resource.opcache
  if new_resource.version.to_f < 5.5
    raise 'Must use PHP >= 5.5 with ius enabled to use Zend Opcache. Try setting '\
        'the `use_ius` property to true and install a proper version of php.'

    new_resource.packages << 'opcache'

    php_ini '10-opcache' do
      options new_resource.opcache_conf
    end
  end
end

include_recipe 'osl-php::packages'

php_install 'default'

php_ini 'timezone' do
  options('date.timezone' => 'UTC')
end

%w(phpcheck phpshow).each do |file|
  cookbook_file "/usr/local/bin/#{file}" do
    source file
    mode '755'
  end
end

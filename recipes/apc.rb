#
# Cookbook:: osl-php
# Recipe:: apc
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
include_recipe 'osl-selinux'

ruby_block 'raise_use_ius_exception' do
  block do
    raise 'APC is not compatible with PHP from IUS Community repos. ' \
          'Try setting node[\'osl-php\'][\'use_ius\'] to false.'
  end
  only_if { node['osl-php']['use_ius'] }
end

ruby_block 'raise_el8_exception' do
  block do
    raise 'APC is not compatible with EL 8.'
  end
  only_if { node['platform_version'].to_i >= 8 }
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

php_ini 'APC' do
  options node['osl-php']['apc']
end

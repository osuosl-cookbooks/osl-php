#
# Cookbook:: osl-php
# Recipe:: composer
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

resource_name :osl_php_composer
provides :osl_php_composer
unified_mode true

property :version, String, default: lazy { composer_version }

action :install do
  # include_recipe 'osl-selinux'
  selinux_install 'osl-selinux'
  selinux_state 'osl-selinux' do
    action :enforcing
  end

  php_install 'default'
  node.default['composer']['url'] = "https://getcomposer.org/download/#{new_resource.version}/composer.phar"
  include_recipe 'composer::default'
end

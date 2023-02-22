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

include_recipe 'osl-selinux::default'

node.default['composer']['url'] = "https://getcomposer.org/download/#{node['osl-php']['composer_version']}/composer.phar"

include_recipe 'php::default'
include_recipe 'composer::default'

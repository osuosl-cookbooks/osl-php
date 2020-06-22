#
# Cookbook:: osl-php
# Recipe:: opcache
#
# Copyright:: 2019-2020, Oregon State University
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

# if trying to use opcache with an incompatible version of php (default pkg)
# and using an unsupported version of php. use_ius must be true to install a valid php interpreter.

if node['osl-php']['use_opcache'] && node['php']['version'].to_f < 5.5
  raise 'Must use PHP >= 5.5 with ius enabled to use Zend Opcache.  Try adding '\
        "'node.default['osl-php']['use_ius'] = true' and install a proper version of php."
end

node.default['osl-php']['php_packages'] << 'opcache'

php_ini '10-opcache' do
  options node['osl-php']['opcache']
  only_if { node['osl-php']['use_opcache'] }
end

#
# Cookbook Name:: osl-php
# Recipe:: apc
#
# Copyright 2013, Oregon State University
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

include_recipe "build-essential"

case node['platform_family']
when 'rhel', 'fedora'
  %w{ httpd-devel pcre pcre-devel }.each do |pkg|
    package pkg do
      action :install
    end
  end
  php_pear 'APC' do
    action :install
  end
when 'debian'
  package 'php-apc' do
    action :install
  end
end

template "/etc/php.d/APC.ini" do
    source "apc.ini.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(:params => node['php']['apc'])
end

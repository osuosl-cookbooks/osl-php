require 'serverspec'

set :backend, :exec

%w(php
   php-devel
   php-fpm
   php-gd
   php-pear).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

%w(
  ius
  ius-archive
).each do |repo|
  describe file "/etc/yum.repos.d/#{repo}.repo" do
    it { should_not exist }
  end
end

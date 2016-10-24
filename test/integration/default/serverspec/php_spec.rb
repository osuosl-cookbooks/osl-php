require 'serverspec'

set :backend, :exec

case os[:family].downcase
when 'redhat', 'fedora', 'centos'
  installed_packages = %w(php-fpm php-gd)
  not_installed_packages = %w(php-apc)
when 'debian', 'ubuntu'
  installed_packages = %w(php5-fpm php5-gd)
  not_installed_packages = %w()
end

installed_packages.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

not_installed_packages.each do |p|
  describe package(p) do
    it { should_not be_installed }
  end
end

require 'serverspec'

set :backend, :exec

%w(mod_php72u
   php72u-devel
   php72u-fpm
   php72u-gd
   pear1u).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

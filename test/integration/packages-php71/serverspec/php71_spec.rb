require 'serverspec'

set :backend, :exec

%w(mod_php71u
   php71u-devel
   php71u-fpm
   php71u-gd
   pear1u).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

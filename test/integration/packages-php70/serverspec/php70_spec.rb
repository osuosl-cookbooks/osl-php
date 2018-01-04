require 'serverspec'

set :backend, :exec

%w(mod_php70u
   php70u-devel
   php70u-fpm
   php70u-gd
   php70u-pear).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

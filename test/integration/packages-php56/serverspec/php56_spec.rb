require 'serverspec'

set :backend, :exec

%w(php56u
   php56u-devel
   php56u-fpm
   php56u-gd
   php56u-pear).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

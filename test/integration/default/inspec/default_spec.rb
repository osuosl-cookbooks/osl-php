%w(php
   php-devel
   php-fpm
   php-gd
   php-pear).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

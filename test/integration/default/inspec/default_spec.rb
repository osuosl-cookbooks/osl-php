%w(php
   php-devel
   php-fpm
   php-gd
   php-pear).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe file('/usr/local/bin/phpcheck') do
  it { should exist }
  it { should be_executable }
end

describe file('/usr/local/bin/phpshow') do
  it { should exist }
  it { should be_executable }
end

describe command('/usr/local/bin/phpcheck -d /var/www test for me') do
  its('stdout') { should match /^phphelpertest$/ }
  its('stdout') { should match /^test_the_second$/ }
end

describe command('/usr/local/bin/phpshow -d /var/www test for me') do
  its('stdout') { should match %r{phphelpertest/test_file.php.+test for me!} }
  its('stdout') { should match %r{test_the_second/me_too.php.+test for me too!} }
end

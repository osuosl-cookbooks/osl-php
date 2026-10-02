# Include selinux tests
include_controls 'selinux'

control 'php_packages' do
  title 'Verify that the php packages are installed and configured'

  %w(php
     php-cli
     php-devel
     php-pear).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  describe file('/etc/php-web.d/mysqlnd-timeout.ini') do
    its('content') { should match /^mysqlnd.net_read_timeout=300$/ }
  end

  describe command('php --ini') do
    its('stdout') { should_not match %r{/etc/php-web.d} }
  end

  describe command('PHP_INI_SCAN_DIR=:/etc/php-web.d php --ini') do
    its('stdout') { should match %r{/etc/php-web.d/mysqlnd-timeout.ini} }
  end

  describe command 'php -i' do
    its('stdout') { should match '/etc/php.d/timezone.ini' }
    its('stdout') { should match 'date.timezone => UTC => UTC' }
    its('stdout') { should match 'Default timezone => UTC' }
  end

  describe file('/usr/local/bin/phpcheck') do
    it { should exist }
    it { should be_executable }
  end

  describe file('/usr/local/bin/phpshow') do
    it { should exist }
    it { should be_executable }
  end

  describe command('/usr/local/bin/phpcheck -h') do
    its('stdout') { should match 'phpcheck help:' }
  end

  describe command('/usr/local/bin/phpshow -h') do
    its('stdout') { should match 'phpshow help:' }
  end

  describe command('/usr/local/bin/phpcheck test for me') do
    its('stdout') { should match /^phphelpertest$/ }
    its('stdout') { should match /^test_the_second$/ }
  end

  describe command('/usr/local/bin/phpshow test for me') do
    its('stdout') { should match %r{phphelpertest/test_file.php.+1.+test for me!} }
    its('stdout') { should match %r{test_the_second/me_too.php.+1.+test for me too!} }
  end
end

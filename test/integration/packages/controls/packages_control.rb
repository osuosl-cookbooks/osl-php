# Include selinux test
include_controls 'selinux'

version = input('version', value: '')

control 'version' do
  title 'Verify that PHP is the correct version'

  only_if 'version is not given' do
    version != ''
  end

  describe command('php --version') do
    its('stdout') { should match version }
  end
end

control 'mod_php' do
  title 'Verify mod_php works'

  only_if 'on RHEL 9+ family' do
    os.release.to_i <= 8
  end

  describe command('curl localhost') do
    its('stdout') { should match /PHP Version #{version}/ }
  end
end

control 'php-fpm' do
  title 'Verify php-fpm works'

  only_if 'not on RHEL 9+ family' do
    os.release.to_i >= 9
  end

  describe http(
    'http://127.0.0.1',
    headers: { 'Host' => 'php_test' }
  ) do
    its('status') { should cmp 200 }
    its('body') { should match /PHP Version #{version}/ }
  end
end

control 'packages RHEL 8+' do
  title 'Verify the correct packages are installed on RHEL 8+ family'

  only_if 'not on RHEL 8+ family' do
    os.release.to_i >= 8
  end

  if version.to_f > 7.2
    describe yum.repo('remi-modular') do
      it { should exist }
      it { should be_enabled }
    end
  end

  php_packages = %w(
    php
    php-pear
    php-devel
    php-fpm
    php-gd
  )

  php_packages.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end

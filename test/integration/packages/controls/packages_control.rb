# Include selinux test
include_controls 'selinux'

version = input('version', value: '')

control 'version' do
  title 'Verify that PHP is the correct version'

  only_if 'version is not given' do
    !version.nil?
  end

  describe command('php --version') do
    its('stdout') { should match version }
  end
end

control 'site' do
  title 'Verify mod_php works'

  describe command('curl localhost') do
    its('stdout') { should match /PHP Version #{version}/ }
  end
end

control 'packages c8' do
  title 'Verify the correct packages are installed on RHEL 8 family'

  only_if 'not on RHEL 8 family' do
    os.release.to_i == 8
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

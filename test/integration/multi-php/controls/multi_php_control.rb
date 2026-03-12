# Include selinux test
include_controls 'selinux'

version1 = input('version1', value: '7.4')
version2 = input('version2', value: '8.1')
short_version1 = version1.delete('.')
short_version2 = version2.delete('.')

control 'remi-safe repo' do
  title 'Verify Remi safe repository is enabled'

  describe yum.repo('remi-safe') do
    it { should exist }
    it { should be_enabled }
  end
end

control 'system php installed' do
  title 'Verify system PHP is installed and functional'

  describe package('php') do
    it { should be_installed }
  end

  describe command('php --version') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/PHP/) }
  end
end

control 'remi php version 1 packages' do
  title "Verify Remi PHP #{version1} packages are installed"

  %W(
    php#{short_version1}-php
    php#{short_version1}-php-cli
    php#{short_version1}-php-devel
    php#{short_version1}-php-fpm
    php#{short_version1}-php-gd
    php#{short_version1}-php-pear
  ).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end

control 'remi php version 1 binary' do
  title "Verify Remi PHP #{version1} binary is functional"

  describe command("/opt/remi/php#{short_version1}/root/usr/bin/php --version") do
    its('exit_status') { should eq 0 }
    its('stdout') { should match version1 }
  end
end

control 'remi php version 2 packages' do
  title "Verify Remi PHP #{version2} packages are installed"

  %W(
    php#{short_version2}-php
    php#{short_version2}-php-cli
    php#{short_version2}-php-devel
    php#{short_version2}-php-fpm
    php#{short_version2}-php-gd
    php#{short_version2}-php-pear
  ).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end

control 'remi php version 2 binary' do
  title "Verify Remi PHP #{version2} binary is functional"

  describe command("/opt/remi/php#{short_version2}/root/usr/bin/php --version") do
    its('exit_status') { should eq 0 }
    its('stdout') { should match version2 }
  end
end

control 'versioned php ini files' do
  title 'Verify ini files are placed in versioned config directories'

  describe file("/etc/opt/remi/php#{short_version1}/php.d/timezone.ini") do
    it { should exist }
    its('content') { should match 'date.timezone=UTC' }
  end

  describe file("/etc/opt/remi/php#{short_version2}/php.d/timezone.ini") do
    it { should exist }
    its('content') { should match 'date.timezone=UTC' }
  end
end

# Include selinux test
include_controls 'selinux'

version = input('version', value: '')
short_version = version.delete('.')

control 'remi-safe repo' do
  title 'Verify Remi safe repository is enabled'

  describe yum.repo('remi-safe') do
    it { should exist }
    it { should be_enabled }
  end
end

control 'remi-safe packages' do
  title 'Verify Remi prefixed packages are installed'

  %W(
    php#{short_version}-php
    php#{short_version}-php-cli
    php#{short_version}-php-devel
    php#{short_version}-php-fpm
    php#{short_version}-php-gd
    php#{short_version}-php-pear
  ).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end

control 'multiple php versions available' do
  title 'Verify both system and Remi PHP binaries are functional'

  describe package('php') do
    it { should be_installed }
  end

  describe command('php --version') do
    its('exit_status') { should eq 0 }
  end

  describe command("/opt/remi/php#{short_version}/root/usr/bin/php --version") do
    its('stdout') { should match version }
    its('exit_status') { should eq 0 }
  end
end


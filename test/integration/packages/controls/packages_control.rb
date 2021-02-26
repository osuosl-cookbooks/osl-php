# Include selinux test
include_controls 'selinux'

control 'packages_config' do
  title 'Verify the correct packages are installed'

  %w(php
     php-devel
     php-fpm
     php-gd
     php-pear).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  %w(
    ius
    ius-archive
  ).each do |repo|
    describe file "/etc/yum.repos.d/#{repo}.repo" do
      it { should_not exist }
    end
  end

  describe package 'php-opcache' do
    it { should_not be_installed }
  end
end

# Include selinux test
include_controls 'selinux'

version = input('version', value: '')
shortver = version.delete('.')

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

control 'packages c7' do
  title 'Verify the correct packages are installed on CentOS 7'

  only_if 'not on CentOS 7' do
    os.release.to_i == 7
  end

  case version
  when '5.6'
    php_packages = %w(
      php56u
      php56u-devel
      php56u-fpm
      php56u-gd
      php56u-pear
      php56u-pecl-imagick
    )

    %w(
      ius
      ius-archive
    ).each do |repo|
      describe yum.repo repo do
        it { should exist }
        it { should be_enabled }
      end
    end

  when '7.2'
    php_packages = %w(
      mod_php72u
      pear1
      php72u-devel
      php72u-fpm
      php72u-gd
      php72u-pecl-imagick
    )

    describe yum.repo('ius') do
      it { should be_enabled }
    end

    # TODO: move to yum.repo check once we've upgraded to a newer InSpec
    describe file '/etc/yum.repos.d/ius.repo' do
      its('content') { should match /^exclude=php73\* php74\*$/ }
    end

    describe yum.repo 'ius-archive' do
      it { should be_enabled }
    end

    # TODO: move to yum.repo check once we've upgraded to a newer InSpec
    describe file '/etc/yum.repos.d/ius-archive.repo' do
      its('content') { should match /^exclude=php5\* php71\* php73\* php74\*$/ }
    end

  when '7.4'
    php_packages = %W(
      mod_php#{shortver}
      pear1
      php#{shortver}-devel
      php#{shortver}-fpm
      php#{shortver}-gd
      php#{shortver}-pecl-imagick
    )

    describe yum.repo('ius') do
      it { should exist }
      it { should be_enabled }
    end

    describe yum.repo('ius-archive') do
      it { should_not be_enabled }
    end

  else
    # assume system packages

    php_packages = %w(
      php
      php-devel
      php-fpm
      php-gd
      php-pear
    )

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

  php_packages.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end

control 'packages c8' do
  title 'Verify the correct packages are installed on CentOS 8'

  only_if 'not on CentOS 8' do
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

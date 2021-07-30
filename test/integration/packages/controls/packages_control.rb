# Include selinux test
include_controls 'selinux'

version = input('version')

control 'packages' do
  title 'Verify the correct packages are installed'

  case version
  when '5.6', '7.1'
    if version == '5.6'
      pkg = %w(
        php56u
        php56u-devel
        php56u-fpm
        php56u-gd
        php56u-pear
        php56u-pecl-imagick
      )
    else
      pkg = %w(
        mod_php71u
        pear1
        php71u-devel
        php71u-fpm
        php71u-gd
        php71u-pecl-imagick
      )

      # TODO: move to yum.repo check once we've upgraded to a newer InSpec
      describe file '/etc/yum.repos.d/ius-archive.repo' do
        its('content') { should match /^exclude=php5\* php72\* php73\* php74\*$/ }
      end
    end

    %w(
      ius
      ius-archive
    ).each do |repo|
      describe yum.repo repo do
        it { should be_enabled }
      end
    end
  when '7.2'
    if os.release.to_i >= 8
      pkg = %w(
        php
        php-devel
        php-fpm
        php-gd
      )
      pkg.each do |p|
        describe package(p) do
          its('version') { should >= '7.2' }
        end
      end

      describe package 'php-pear' do
        it { should be_installed }
      end

      describe yum.repo 'ius' do
        it { should_not exist }
        it { should_not be_enabled }
      end

      describe file '/etc/yum.repos.d/ius.repo' do
        it { should_not exist }
      end
    else
      pkg = %w(
        mod_php72u
        pear1
        php72u-devel
        php72u-fpm
        php72u-gd
        php72u-pecl-imagick
      )

      describe yum.repo 'ius' do
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
    end
  when '7.3', '7.4'
    pkg = if version == '7.3'
            %w(
              mod_php73
              pear1
              php73-devel
              php73-fpm
              php73-gd
              php73-pecl-imagick
            )
          else
            %w(
              mod_php74
              pear1
              php74-devel
              php74-fpm
              php74-gd
              php74-pecl-imagick
            )
          end
    describe yum.repo 'ius' do
      it { should be_enabled }
    end

    describe file '/etc/yum.repos.d/ius.repo' do
      it { should exist }
    end

    describe yum.repo 'ius-archive' do
      it { should_not be_enabled }
    end
  else
    pkg = %w(
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

  pkg.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end

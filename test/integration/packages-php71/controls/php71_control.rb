# Include selinux tests
include_controls 'selinux'

control 'packages-php71_config' do
  title 'Verify php71 packages are installed'

  %w(mod_php71u
     pear1
     php71u-devel
     php71u-fpm
     php71u-gd
     php71u-pecl-imagick
  ).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
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

  # TODO: move to yum.repo check once we've upgraded to a newer InSpec
  describe file '/etc/yum.repos.d/ius-archive.repo' do
    its('content') { should match /^exclude=php5\* php72\* php73\* php74\*$/ }
  end
end

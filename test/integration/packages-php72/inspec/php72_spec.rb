if os.release.to_i >= 8
  %w(
    php
    php-devel
    php-fpm
    php-gd
  ).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
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
  %w(
    mod_php72u
    pear1
    php72u-devel
    php72u-fpm
    php72u-gd
    php72u-pecl-imagick
  ).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  describe yum.repo 'ius' do
    it { should be_enabled }
  end

  # TODO: move to yum.repo check once we've upgraded to a newer InSpec
  describe file '/etc/yum.repos.d/ius.repo' do
    its('content') { should match /^exclude=php73\* php74\*$/ }
  end

end

describe yum.repo 'ius-archive' do
  it { should_not exist }
  it { should_not be_enabled }
end

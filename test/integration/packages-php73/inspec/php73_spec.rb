%w(
  mod_php73
  pear1
  php73-devel
  php73-fpm
  php73-gd
  php73-pecl-imagick
).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
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

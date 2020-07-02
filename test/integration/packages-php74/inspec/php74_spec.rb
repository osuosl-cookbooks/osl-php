%w(
  mod_php74
  pear1
  php74-devel
  php74-fpm
  php74-gd
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
  it { should_not exist }
  it { should_not be_enabled }
end

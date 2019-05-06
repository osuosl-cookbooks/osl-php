%w(mod_php72u
   php72u-devel
   php72u-fpm
   php72u-gd
   pear1u).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe file '/etc/yum.repos.d/ius.repo' do
  its(:content) { should match(/^enabled=1$/) }
end

describe file '/etc/yum.repos.d/ius-archive.repo' do
  it { should_not exist }
end

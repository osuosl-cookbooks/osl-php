require 'serverspec'

set :backend, :exec

%w(mod_php71u
   php71u-devel
   php71u-fpm
   php71u-gd
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

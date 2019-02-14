require 'serverspec'

set :backend, :exec

%w(php56u
   php56u-devel
   php56u-fpm
   php56u-gd
   php56u-pear).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe file '/etc/yum.repos.d/ius-archive.repo' do
  its(:content) { should match(/^enabled=1$/) }
end

require 'serverspec'

set :backend, :exec

%w(httpd-devel pcre pcre-devel).each do |pkg|
  describe package pkg do
    it { should be_installed }
  end
end

describe file '/etc/php.d' do
  it { should exist }
  it { should be_directory }
end

describe file '/etc/php.d/APC.ini' do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_mode 644 }
  its(:content) { should contain '128M' }
end

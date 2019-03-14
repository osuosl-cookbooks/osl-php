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
end

describe command 'echo "<?php phpinfo(); ?>" | php' do
  its(:stdout) { should match /apc.shm_size.+128M/ }
  its(:stdout) { should match /enable_cli.+Off/ }
  its(:stdout) { should match /ttl.+3600/ }
  its(:stdout) { should match /apc.user_ttl.+7200/ }
  its(:stdout) { should match /gc_ttl.+3600/ }
  its(:stdout) { should match /max_file_size.+1M/ }
  its(:stdout) { should match /stat.+1/ }
end

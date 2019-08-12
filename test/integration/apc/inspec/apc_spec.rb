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
  its('mode') { should cmp '0644' }
end

['echo "<?php phpinfo(); ?>" | php', 'curl localhost'].each do |cmd|
  describe command cmd do
    its(:stdout) { should match /apc.shm_size.+128M/ }
    its(:stdout) { should match /apc.enable_cli.+Off/ }
    its(:stdout) { should match /apc.ttl.+3600/ }
    its(:stdout) { should match /apc.user_ttl.+7200/ }
    its(:stdout) { should match /apc.gc_ttl.+3600/ }
    its(:stdout) { should match /apc.max_file_size.+1M/ }
    its(:stdout) { should match /apc.stat.+On/ }
  end
end

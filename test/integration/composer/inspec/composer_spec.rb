describe file('/usr/local/bin/composer') do
  it { should exist }
end

describe command('/usr/local/bin/composer --version') do
  its(:stdout) { should match 'Composer version 1.9.1' }
end

describe file('/usr/local/bin/composer') do
  it { should exist }
end

describe command('/usr/local/bin/composer --version') do
  its(:stdout) { should contain('Composer version 1.2.1') }
end

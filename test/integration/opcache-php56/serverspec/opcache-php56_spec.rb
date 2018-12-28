require 'serverspec'

set :backend, :exec

describe command 'echo "<?php phpinfo(); ?>" | php' do
  its(:stdout) { should match /PHP Version.*5.6/ }
  its(:stdout) { should match /opcache\.memory_consumption.+1024/ }
  its(:stdout) { should match /opcache\.max_accelerated_files.+1000/ }
end

describe command 'curl localhost' do
  its(:stdout) { should match /PHP Version.*5.6/ }
  its(:stdout) { should match /opcache\.memory_consumption.+1024/ }
  its(:stdout) { should match /opcache\.max_accelerated_files.+1000/ }
end

describe package 'php56u-opcache' do
  it { should be_installed }
end

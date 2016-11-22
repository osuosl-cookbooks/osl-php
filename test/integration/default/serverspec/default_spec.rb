require 'serverspec'

set :backend, :exec

if os[:family] == 'debian'
  describe file('/usr/bin/php') do
    it { should exist }
  end
else
  describe package('php') do
    it { should be_installed }
  end
end

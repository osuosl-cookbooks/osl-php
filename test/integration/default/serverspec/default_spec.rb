require 'serverspec'

set :backend, :exec

describe package('php') do
  it { should be_installed }
end

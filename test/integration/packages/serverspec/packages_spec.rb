require 'serverspec'

set :backend, :exec

describe package('php-fpm') do
  it { should be_installed }
end

describe package('php-gd') do
  it { should be_installed }
end

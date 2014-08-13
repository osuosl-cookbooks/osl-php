require 'serverspec'

include Serverspec::Helper::DetectOS
include Serverspec::Helper::Exec

%w[ php-fpm php-gd ].each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe package('php-apc') do
  it { should_not be_installed }
end

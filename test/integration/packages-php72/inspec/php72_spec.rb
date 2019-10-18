%w(mod_php72u
   php72u-devel
   php72u-fpm
   php72u-gd
   pear1).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe yum.repo 'ius' do
  it { should be_enabled }
end

# TODO: move to yum.repo check once we've upgraded to a newer InSpec
describe file '/etc/yum.repos.d/ius.repo' do
  its('content') { should match /^exclude=php73\*$/ }
end

describe yum.repo 'ius-archive' do
  it { should_not exist }
  it { should_not be_enabled }
end
%w(mod_php71u
   php71u-devel
   php71u-fpm
   php71u-gd
   pear1
).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

%w(
  ius
  ius-archive
).each do |repo|
  describe yum.repo repo do
    it { should be_enabled }
  end
end

# TODO: move to yum.repo check once we've upgraded to a newer InSpec
describe file '/etc/yum.repos.d/ius.repo' do
  its('content') { should match /^exclude=php72\* php73\*$/ }
end

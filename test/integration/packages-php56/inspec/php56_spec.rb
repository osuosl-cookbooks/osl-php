%w(
  php56u
  php56u-devel
  php56u-fpm
  php56u-gd
  php56u-pear
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

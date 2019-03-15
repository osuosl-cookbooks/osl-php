require 'serverspec'

set :backend, :exec

%w(php53u
   php53u-devel
   php53u-fpm
   php53u-gd
   php53u-pear).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

%w(
  ius
  ius-archive
).each do |repo|
  describe file "/etc/yum.repos.d/#{repo}.repo" do
    its(:content) { should match(/^enabled=1$/) }
    if repo == 'ius'
      if os[:release].to_i >= 7
        its(:content) { should match(%r{^baseurl=http://ftp.osuosl.org/pub/osl/repos/yum/\$releasever/php53/\$basearch$}) }
        its(:content) { should match(%r{^gpgkey=http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl$}) }
        its(:content) { should_not match(/^mirrorlist/) }
      else
        its(:content) { should_not match(%r{^baseurl=http://ftp.osuosl.org/pub/osl/repos/yum/\$releasever/php53/\$basearch$}) }
        its(:content) { should_not match(%r{^gpgkey=http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl$}) }
        its(:content) { should match(/^mirrorlist/) }
      end
    end
  end
end

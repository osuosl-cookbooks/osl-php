%w(php
   php-devel
   php-fpm
   php-gd
   php-pear).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe file('/usr/local/bin/phpcheck') do
  it { should exist }
  its('content') { should match %r{find . -name '*.php' -or -name '*.ini' | grep -v '/geshi/' | xargs grep -H -T -e "$*" | cut -d/ -f2 | uniq} }
end

describe file('/usr/local/bin/phpshow') do
  it { should exist }
  its('content') { should match %r{find . -name '*.php' -or -name '*.ini' | grep -v '/geshi/' | xargs grep --color=auto -H -T -e "$*"} }
end

# inspec does not handle chaining commands nor bash -c "$cmds"
# describe command('cd /var/www; phpcheck test for me') do
#   its('stdout') { should cmp 'phphelpertest' }
#   its('stdout') { should cmp 'test_the_second' }
# end
#
# describe command('cd /var/www; phpshow test for me') do
#   its('stdout') { should match './phphelpertest/test_file.php' }
#   its('stdout') { should match './test_the_second/me_too.php' }
# end

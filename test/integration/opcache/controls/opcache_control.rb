# Include selinux tests
include_controls 'selinux'

version = input('version')

control 'opcache' do
  title 'Verify opcache package is installed and configured'

  ['echo "<?php phpinfo(); ?>" | php', 'curl -H "Host: php_test" localhost'].each do |cmd|
    describe command cmd do
      its('stdout') { should match /PHP Version.*#{version}/ }
      its('stdout') { should match /opcache\.memory_consumption.+1024/ }
      its('stdout') { should match /opcache\.max_accelerated_files.+1000/ }
      its('stdout') { should match /opcache\.enable.+On/ }
      its('stdout') { should match /opcache\.interned_strings_buffer.+8/ }
      its('stdout') { should match %r{opcache\.blacklist_filename.+/etc/php\.d/opcache\*\.blacklist} }
    end
  end

  describe package 'php-opcache' do
    it { should be_installed }
    its('version') { should >= version }
  end
end

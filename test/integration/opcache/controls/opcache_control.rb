# Include selinux tests
include_controls 'selinux'

version = input('version')

control 'opcache' do
  title 'Verify opcache package is installed and configured'

  ['echo "<?php phpinfo(); ?>" | php', 'curl localhost'].each do |cmd|
    describe command cmd do
      case version
      when '5.6'
        its(:stdout) { should match /PHP Version.*5.6/ }
      when '7.2'
        its(:stdout) { should match /PHP Version.*7.2/ }
      end
      its(:stdout) { should match /opcache\.memory_consumption.+1024/ }
      its(:stdout) { should match /opcache\.max_accelerated_files.+1000/ }
      its(:stdout) { should match /opcache\.enable.+On/ }
      its(:stdout) { should match /opcache\.interned_strings_buffer.+8/ }
      its(:stdout) { should match %r{opcache\.blacklist_filename.+/etc/php\.d/opcache\*\.blacklist} }
    end
  end

  case version
  when '5.6'
    describe package 'php56u-opcache' do
      it { should be_installed }
    end
  when '7.2'
    if os.release.to_i >= 8
      describe package 'php-opcache' do
        it { should be_installed }
        its('version') { should >= '7.2' }
      end
    else
      describe package 'php72u-opcache' do
        it { should be_installed }
      end
    end
  end
end

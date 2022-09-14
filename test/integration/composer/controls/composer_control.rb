# Include selinux test
include_controls 'selinux'

control 'composer_config' do
  title 'Verify that composer is installed with the correct version'

  describe file('/usr/local/bin/composer') do
    it { should exist }
  end

  describe command('/usr/local/bin/composer --version') do
    its(:stdout) { should match 'Composer version 2.2.18' }
  end
end

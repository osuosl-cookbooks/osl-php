# Include selinux tests
include_controls 'selinux'

control 'php-ini_config' do
  title 'Verify php ini files are correct'

  no_sections_static = inspec.file('/tmp/no_sections_static').content
  with_sections_static = inspec.file('/tmp/with_sections_static').content

  describe file('/etc/php.d/no_sections_rendered.ini') do
    its('content') { should match no_sections_static }
  end

  describe file('/etc/php.d/with_sections_rendered.ini') do
    its('content') { should match with_sections_static }
  end

  describe file('/etc/php.d/no_sections_rendered_removed.ini') do
    it { should_not exist }
  end
end

# Include selinux test
include_controls 'selinux'

version = input('version', value: '')

php_dir = if version.empty?
            '/etc/php.d'
          else
            "/etc/opt/remi/php#{version.delete('.')}/php.d"
          end

control 'php-ini' do
  title 'Verify php ini files are correct'

  no_sections_static = inspec.file('/tmp/no_sections_static').content
  with_sections_static = inspec.file('/tmp/with_sections_static').content

  describe file("#{php_dir}/no_sections_rendered.ini") do
    its('content') { should match no_sections_static }
  end

  describe file("#{php_dir}/with_sections_rendered.ini") do
    its('content') { should match with_sections_static }
  end

  describe file("#{php_dir}/no_sections_rendered_removed.ini") do
    it { should_not exist }
  end
end

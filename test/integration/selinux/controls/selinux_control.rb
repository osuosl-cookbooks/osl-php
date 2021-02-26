control 'selinux_config' do
  title 'Verify that selinux is configured in enforcing mode'

  describe file('/var/log/audit/audit.log') do
    its('content') { should_not match /^type=AVC/ }
  end
end

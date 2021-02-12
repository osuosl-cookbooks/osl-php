describe file('/var/log/audit/audit.log') do
  its('content') { should_not match /^type=AVC/ }
end

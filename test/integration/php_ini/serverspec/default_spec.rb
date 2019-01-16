require 'serverspec'

set :backend, :exec

no_sections_static = File.read('/tmp/no_sections_static')
with_sections_static = File.read('/tmp/with_sections_static')

describe file('/etc/php.d/no_sections_rendered.ini') do
  its('content') { should match no_sections_static }
end

describe file('/etc/php.d/with_sections_rendered.ini') do
  its('content') { should match with_sections_static }
end

describe file('/etc/php.d/no_sections_rendered_removed.ini') do
  it { should_not exist }
end

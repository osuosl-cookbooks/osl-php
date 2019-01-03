require 'serverspec'

set :backend, :exec

no_sections_static = File.read('/no_sections_static')
with_sections_static = File.read('/with_sections_static')

describe file('/no_sections_rendered') do
  its('content') { should match no_sections_static }
end

describe file('/with_sections_rendered') do
  its('content') { should match with_sections_static }
end

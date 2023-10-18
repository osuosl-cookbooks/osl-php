php_install 'packages' do
  packages node['packages']
  unprefixed_names %w(devel cli)
  version node['version']
end

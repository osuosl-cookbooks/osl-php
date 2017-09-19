if defined?(ChefSpec)
  ChefSpec.define_matcher :php_pear
  def install_php_pear(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:php_pear, :install, resource_name)
  end
end

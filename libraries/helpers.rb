module OslPhp
  module Cookbook
    module Helpers
      def system_php?
        # If didn't change this to 7.2 or 7.3, etc then let's assume we're using the system php package
        node['php']['version'].match?(/\d+\.\d+\.\d+/)
      end
    end
  end
end
Chef::DSL::Recipe.include ::OslPhp::Cookbook::Helpers
Chef::Resource.include ::OslPhp::Cookbook::Helpers

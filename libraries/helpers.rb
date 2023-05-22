module OslPhp
  module Cookbook
    module Helpers
      def system_php?
        # If didn't change this to 7.2 or 7.3, etc then let's assume we're using the system php package
        node['php']['version'].match?(/\d+\.\d+\.\d+/)
      end

      def osl_php_available_ram
        total_ram = (node['memory']['total'].split('kB')[0].to_i / 1024) # in MB
        reserved_ram = 1024
        buffer = total_ram * 0.1

        # [Total Available RAM] - [Reserved RAM] - [10% buffer] = [Available RAM for PHP]
        php_ram = (total_ram - reserved_ram - buffer).floor
        # If we get a negative number, just make it zero
        if php_ram < 0
          0
        else
          php_ram
        end
      end

      # process_size: in MB
      def osl_php_fpm_settings(process_size)
        # https://chrismoore.ca/2018/10/finding-the-correct-pm-max-children-settings-for-php-fpm/
        # https://github.com/spot13/pmcalculator

        # Run the following to figure the RSS size of php-fpm: ps -ylC php-fpm
        # [Available RAM for PHP] / [Average Process Size] = [max_children]
        max_children = (osl_php_available_ram / process_size).floor

        # If we have zero, just a minimum of 4
        max_children = 4 if max_children == 0

        start_servers = (max_children * 0.25).floor
        min_spare_servers = (max_children * 0.25).floor
        max_spare_servers = (max_children * 0.75).floor

        {
          'max_children' => max_children,
          'start_servers' => start_servers,
          'min_spare_servers' => min_spare_servers,
          'max_spare_servers' => max_spare_servers,
        }
      end
    end
  end
end
Chef::DSL::Recipe.include ::OslPhp::Cookbook::Helpers
Chef::Resource.include ::OslPhp::Cookbook::Helpers

module OslPhp
  module Cookbook
    module Helpers
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

      def osl_php_default_composer_version
        '2.2.18'
      end

      # defaults from php72u-opcache package on CentOS 7
      def osl_php_opcache_conf
        {
          'zend_extension' => 'opcache.so',
          'opcache.blacklist_filename' => '/etc/php.d/opcache*.blacklist',
          'opcache.enable' => 1,
          'opcache.interned_strings_buffer' => 8,
          'opcache.max_accelerated_files' => 4000,
          'opcache.memory_consumption' => 128,
        }
      end

      # process_size: in MB
      def osl_php_fpm_settings(process_size)
        # https://chrismoore.ca/2018/10/finding-the-correct-pm-max-children-settings-for-php-fpm/
        # https://github.com/spot13/pmcalculator

        # Run the following to figure out the RSS size of php-fpm: ps -ylC php-fpm
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

      def osl_php_default_installation_packages_without_prefixes
        (php_installation_packages.map { |p| p[/^php[0-9u]*-(.*)/, 1] } - ['pear'] - [nil])
      end
    end
  end
end
Chef::DSL::Recipe.include ::OslPhp::Cookbook::Helpers
Chef::Resource.include ::OslPhp::Cookbook::Helpers

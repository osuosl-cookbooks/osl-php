require_relative '../../spec_helper'

describe 'osl_php_apc' do
  platform 'centos', '7'
  step_into :osl_php_apc

  cached(:chef_run) do
    chef_runner.converge('php_test::blank') do
      recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

      recipe.instance_exec do
        osl_php_apc 'default'
      end
    end
  end

  it { is_expected.to include_recipe 'osl-selinux' }
  it { is_expected.to install_package(%w(httpd-devel pcre pcre-devel)) }
  it { is_expected.to install_php_pear('APC').with(channel: 'pecl.php.net') }

  it do
    is_expected.to add_osl_php_ini('APC').with(
      options: {
        'extension' => 'apc.so',
        'apc.shm_size' => '128M',
        'apc.user_ttl' => 7200,
        'apc.enable_cli' => 0,
        'apc.ttl' => 3600,
        'apc.gc_ttl' => 3600,
        'apc.max_file_size' => '1M',
        'apc.stat' => 1,
      }
    )
  end

  context 'options' do
    cached(:subject) { chef_run }
    step_into :osl_php_apc

    cached(:chef_run) do
      chef_runner.converge('php_test::blank') do
        recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

        recipe.instance_exec do
          osl_php_apc 'options' do
            options(
              'extension' => 'apc.so',
              'apc.shm_size' => '64M',
              'apc.user_ttl' => 12800,
              'apc.enable_cli' => 1,
              'apc.ttl' => 7200,
              'apc.gc_ttl' => 7200,
              'apc.max_file_size' => '4M',
              'apc.stat' => 0
            )
          end
        end
      end
    end

    it do
      is_expected.to add_osl_php_ini('APC').with(
        options: {
          'extension' => 'apc.so',
          'apc.shm_size' => '64M',
          'apc.user_ttl' => 12800,
          'apc.enable_cli' => 1,
          'apc.ttl' => 7200,
          'apc.gc_ttl' => 7200,
          'apc.max_file_size' => '4M',
          'apc.stat' => 0,
        }
      )
    end
  end

  context 'EL 8' do
    platform 'almalinux', '8'
    cached(:chef_run) do
      chef_runner.converge('php_test::blank') do
        recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

        recipe.instance_exec do
          osl_php_apc 'default'
        end
      end
    end

    it do
      is_expected.to run_ruby_block('raise_el8_exception')
    end
  end
end

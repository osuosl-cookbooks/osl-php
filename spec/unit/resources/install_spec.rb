require_relative '../../spec_helper'

describe 'osl_php_install' do
  platform 'almalinux', '9'
  step_into :osl_php_install

  cached(:chef_run) do
    chef_runner.converge('php_test::blank') do
      recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

      recipe.instance_exec do
        osl_php_install 'default packages'
      end
    end
  end

  # using packages with non-versioned prefixes

  it { is_expected.to include_recipe 'osl-selinux' }
  it { is_expected.to include_recipe 'osl-repos::epel' }
  it { is_expected.to add_osl_php_ini('timezone').with(options: { 'date.timezone' => 'UTC' }) }
  it { is_expected.to_not add_osl_php_ini '10-opcache' }
  it { is_expected.to install_php_install('default packages all packages').with(packages: %w(php-devel php-cli php)) }
  it { is_expected.to install_package('php-pear') }

  it do
    is_expected.to create_cookbook_file('/usr/local/bin/phpcheck').with(
      path: '/usr/local/bin/phpcheck',
      source: 'phpcheck',
      mode: '755',
      cookbook: 'osl-php'
    )
  end

  it do
    is_expected.to create_cookbook_file('/usr/local/bin/phpshow').with(
      path: '/usr/local/bin/phpshow',
      source: 'phpshow',
      mode: '755',
      cookbook: 'osl-php'
    )
  end

  it { is_expected.to delete_directory('/etc/httpd/conf.modules.d') }
  it { is_expected.to delete_directory('/etc/httpd/conf.d') }

  context 'Almalinux 8' do
    platform 'almalinux', '8'
    step_into :osl_php_install

    cached(:chef_run) do
      chef_runner.converge('php_test::blank') do
        recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

        recipe.instance_exec do
          osl_php_install 'default packages'
        end
      end
    end

    # using packages with non-versioned prefixes
    it { is_expected.to install_php_install('default packages all packages').with(packages: %w(php-devel php-cli php)) }
    it { is_expected.to install_package('php-pear') }
  end

  context 'Using OPcache' do
    cached(:chef_run) do
      chef_runner.converge('php_test::blank') do
        recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

        recipe.instance_exec do
          osl_php_install 'defaults with opcache' do
            use_opcache true
          end
        end
      end
    end

    it do
      is_expected.to add_osl_php_ini('10-opcache').with(
        options: {
          'opcache.blacklist_filename' => '/etc/php.d/opcache*.blacklist',
          'opcache.enable' => 1,
          'opcache.interned_strings_buffer' => 8,
          'opcache.max_accelerated_files' => 4000,
          'opcache.memory_consumption' => 128,
          'zend_extension' => 'opcache.so',
        }
      )
      is_expected.to install_php_install('defaults with opcache all packages').with(packages: %w(php-devel php-cli php php-opcache))
    end

    context 'OPCache with conf' do
      cached(:chef_run) do
        chef_runner.converge('php_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

          recipe.instance_exec do
            osl_php_install 'defaults with opcache conf' do
              use_opcache true
              opcache_conf(
                'opcache.memory_consumption' => 256,
                'opcache.enable_cli' => 1,
                'opcache.taco salad' => 'without the shell, please.'
              )
            end
          end
        end
      end
      it do
        is_expected.to add_osl_php_ini('10-opcache').with(
          options: {
            'opcache.blacklist_filename' => '/etc/php.d/opcache*.blacklist',
            'opcache.enable' => 1,
            'opcache.enable_cli' => 1,
            'opcache.interned_strings_buffer' => 8,
            'opcache.max_accelerated_files' => 4000,
            'opcache.memory_consumption' => 256,
            'opcache.taco salad' => 'without the shell, please.',
            'zend_extension' => 'opcache.so',
          }
        )
      end
    end
  end

  context 'Composer' do
    cached(:chef_run) do
      chef_runner.converge('php_test::blank') do
        recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

        recipe.instance_exec do
          osl_php_install 'defaults with composer' do
            use_composer true
          end
        end
      end
    end
    it do
      is_expected.to create_if_missing_remote_file('/usr/local/bin/composer').with(
        source: 'https://getcomposer.org/download/2.2.18/composer.phar',
        mode: '755'
      )
    end

    context 'Composer version' do
      cached(:chef_run) do
        chef_runner.converge('php_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

          recipe.instance_exec do
            osl_php_install 'defaults with composer version' do
              use_composer true
              composer_version '2.2.17'
            end
          end
        end
      end
      it do
        is_expected.to create_if_missing_remote_file('/usr/local/bin/composer').with(
          source: 'https://getcomposer.org/download/2.2.17/composer.phar'
        )
      end
    end
  end

  %w(7.2 7.4 8.0 8.1 8.2 8.3 8.4).each do |version|
    context "using packages with versioned prefixes: php #{version}" do
      platform 'almalinux', '9'
      cached(:chef_run) do
        chef_runner.converge('php_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

          recipe.instance_exec do
            osl_php_install 'packages' do
              php_packages %w(devel)
              version version
            end
          end
        end
      end

      it { is_expected.to add_osl_repos_alma('default') }

      it do
        case version
        when '7.2'
          is_expected.to create_yum_remi_php72('default')
        when '7.4'
          is_expected.to create_yum_remi_php74('default')
        end
      end

      it { is_expected.to install_php_install('packages all packages').with(packages: %w(php-devel php)) }
      it { is_expected.to install_package('php-pear') }
    end

    context 'Almalinux 8' do
      platform 'almalinux', '8'
      step_into :osl_php_install

      cached(:chef_run) do
        chef_runner.converge('php_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

          recipe.instance_exec do
            osl_php_install 'packages' do
              php_packages %w(devel)
              version version
            end
          end
        end
      end

      it { is_expected.to install_php_install('packages all packages').with(packages: %w(php-devel php)) }
      it { is_expected.to install_package('php-pear') }
    end
  end
end

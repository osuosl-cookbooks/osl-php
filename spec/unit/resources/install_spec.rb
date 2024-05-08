require_relative '../../spec_helper'

describe 'osl_php_install' do
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

  it { is_expected.to include_recipe 'osl-selinux' }
  it { is_expected.to include_recipe 'osl-repos::epel' }
  it { is_expected.to add_osl_php_ini('timezone').with(options: { 'date.timezone' => 'UTC' }) }
  it { is_expected.to_not add_osl_php_ini '10-opcache' }
  it { is_expected.to install_php_install('all-packages').with(packages: %w(php-devel php-cli php)) }
  it { is_expected.to_not install_package(%w(pecl-imagick mod_php php-opcache pear1)) }
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

  context 'Using IUS' do
    cached(:chef_run) do
      chef_runner.converge('php_test::blank') do
        recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

        recipe.instance_exec do
          osl_php_install 'defaults with ius' do
            use_ius true
          end
        end
      end
    end

    it do
      is_expected.to_not include_recipe('yum-ius')
    end
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
      is_expected.to install_php_install('all-packages').with(packages: %w(php-devel php-cli php php-opcache))
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

    context 'Fail OPcache due to version' do
      cached(:chef_run) do
        chef_runner.converge('php_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

          recipe.instance_exec do
            osl_php_install 'fail opcache' do
              use_opcache true
              version '5.4'
            end
          end
        end
      end

      it do
        expect { chef_run }.to raise_error(RuntimeError, /Must use PHP >= 5.5 to use OPcache./)
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

  context 'CentOS 7' do
    platform 'centos', '7'
    cached(:chef_run) do
      chef_runner.converge('php_test::blank') do
        recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

        recipe.instance_exec do
          osl_php_install 'default packages'
        end
      end
    end
    it { is_expected.to install_php_install('all-packages').with(packages: %w(php-devel php-cli php)) }
    it { is_expected.to install_package('php-pear') }

    context 'Using IUS' do
      cached(:chef_run) do
        chef_runner.converge('php_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

          recipe.instance_exec do
            osl_php_install 'defaults with ius' do
              use_ius true
            end
          end
        end
      end
      it { is_expected.to add_osl_repos_centos('default').with(exclude: []) }
      it { is_expected.to create_yum_repository 'osuosl' }
      it { is_expected.to include_recipe 'yum-ius' }
      it { is_expected.to install_php_install('all-packages').with(packages: %w(php74-devel php74-cli mod_php74)) }
      it { is_expected.to install_package('pear1') }
    end

    context 'Using OPCache' do
      cached(:chef_run) do
        chef_runner.converge('php_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

          recipe.instance_exec do
            osl_php_install 'defaults with opcache' do
              use_opcache true
              use_ius true
            end
          end
        end
      end
      it do
        is_expected.to install_php_install('all-packages').with(
          packages: %w(php74-devel php74-cli mod_php74 php74-opcache)
        )
      end

      context 'Fail OPcache due to no IUS' do
        cached(:chef_run) do
          chef_runner.converge('php_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

            recipe.instance_exec do
              osl_php_install 'fail opcache' do
                use_opcache true
              end
            end
          end
        end

        it do
          expect { chef_run }.to raise_error(RuntimeError, /Must use PHP >= 5.5 with IUS enabled to use OPcache./)
        end
      end
    end
  end

  context 'using packages without prefixes' do
    cached(:chef_run) do
      chef_runner.converge('php_test::blank') do
        recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

        recipe.instance_exec do
          osl_php_install 'packages' do
            packages %w(graphviz-php pecl-imagick php-cli)
          end
        end
      end
    end

    it { is_expected.to install_php_install('all-packages').with(packages: %w(graphviz-php php-cli php)) }
    it { is_expected.to_not install_package('pecl-imagick') }
    it { is_expected.to install_package('php-pear') }
    it { is_expected.not_to install_package(%w(php-graphviz-php php-pecl-imagick php-php-cli php-devel)) }

    context 'Using OPcache' do
      cached(:chef_run) do
        chef_runner.converge('php_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

          recipe.instance_exec do
            osl_php_install 'non-prefixed packages with opcache' do
              packages %w(graphviz-php pecl-imagick php-cli)
              use_opcache true
            end
          end
        end
      end
      it do
        is_expected.to install_php_install('all-packages').with(packages: %w(graphviz-php php-cli php php-opcache))
      end
    end

    context 'Using OPcache' do
      platform 'centos', '7'
      cached(:chef_run) do
        chef_runner.converge('php_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

          recipe.instance_exec do
            osl_php_install 'non-prefixed packages with opcache' do
              packages %w(graphviz-php pecl-imagick php-cli)
              use_ius true
              use_opcache true
            end
          end
        end
      end
      it do
        is_expected.to install_php_install('all-packages').with(
          packages: %w(graphviz-php pecl-imagick php-cli mod_php74 php74-opcache)
        )
      end
    end
  end

  %w(5.6 7.2 7.4).each do |version|
    context "using packages with versioned prefixes: php #{version}" do
      platform 'almalinux', '8'
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
        when '5.6'
          is_expected.to create_yum_remi_php56('default')
        when '7.2'
          is_expected.to create_yum_remi_php72('default')
        when '7.4'
          is_expected.to create_yum_remi_php74('default')
        end
      end

      it { is_expected.to install_php_install('all-packages').with(packages: %w(php-devel php)) }
      it { is_expected.to install_package('php-pear') }
      it { is_expected.to_not install_package(%w(pecl-imagick php-cli)) }

      context 'CentOS 7' do
        platform 'centos', '7'
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

        if version.to_i >= 7
          it { is_expected.to install_php_install('all-packages').with(packages: %w(php-devel mod_php)) }
        else
          it { is_expected.to install_php_install('all-packages').with(packages: %w(php-devel php)) }
        end

        it { is_expected.to install_package('php-pear') }

        it { is_expected.to_not install_package('pecl-imagick php-cli') }

        context 'Using IUS' do
          cached(:chef_run) do
            chef_runner.converge('php_test::blank') do
              recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

              recipe.instance_exec do
                osl_php_install 'packages' do
                  php_packages %w(devel)
                  version version
                  use_ius true
                end
              end
            end
          end
          prefix = "php#{version.delete('.')}#{version.to_f < 7.3 ? 'u' : ''}"

          it { is_expected.to add_osl_repos_centos('default').with(exclude: %w(ImageMagick*)) } if version.to_f <= 7.1
          it { is_expected.to add_osl_repos_centos('default').with(exclude: []) } if version.to_f > 7.1
          it { is_expected.to include_recipe 'yum-ius' }

          if version.to_f >= 7
            it do
              is_expected.to install_php_install('all-packages').with(packages: ["#{prefix}-devel", "mod_#{prefix}"])
            end
            it { is_expected.to install_package('pear1') }
          else
            it do
              is_expected.to install_php_install('all-packages').with(packages: ["#{prefix}-devel", "#{prefix}"])
            end
            it { is_expected.to install_package("#{prefix}-pear") }
          end
        end

        context 'Using OPcache' do
          cached(:chef_run) do
            chef_runner.converge('php_test::blank') do
              recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)

              recipe.instance_exec do
                osl_php_install 'packages' do
                  php_packages %w(devel)
                  version version
                  use_ius true
                  use_opcache true
                end
              end
            end
          end
          it do
            prefix = "php#{version.delete('.')}#{version.to_f < 7.3 ? 'u' : ''}"
            if version.to_i == 7
              is_expected.to install_php_install('all-packages').with(packages: ["#{prefix}-devel", "mod_#{prefix}", "#{prefix}-opcache"])
            else
              is_expected.to install_php_install('all-packages').with(packages: ["#{prefix}-devel", "#{prefix}", "#{prefix}-opcache"])
            end
          end
        end
      end
    end
  end
end

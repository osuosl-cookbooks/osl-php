require_relative '../../spec_helper'

describe 'osl_php_install' do
  cached(:subject) { chef_run }
  platform 'almalinux', '8'
  step_into :osl_php_install

  # using packages with non-versioned prefixes

  recipe do
    osl_php_install 'default packages'
  end

  it do
    is_expected.to install_selinux_install('osl-selinux')
    is_expected.to enforcing_selinux_state('osl-selinux')

    # php_version is 7.2 by default for RHEL
    is_expected.to add_osl_repos_epel('default').with(exclude: %w(php73* php74*))

    # elements from the spec for the old default recipe
    is_expected.to add_osl_php_ini('timezone').with(options: { 'date.timezone' => 'UTC' })
    is_expected.to_not add_osl_php_ini('10-opcache')

    is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-cli php-pear))
    is_expected.to_not install_package(%w(pecl-imagick mod_php php-opcache pear1))
    # Don't install php-pear twice since it's already part of default packages
    is_expected.to_not install_package('php-pear')

    is_expected.to create_cookbook_file('/usr/local/bin/phpcheck').with(
      path: '/usr/local/bin/phpcheck',
      source: 'phpcheck',
      mode: '755',
      cookbook: 'osl-php'
    )
    is_expected.to create_cookbook_file('/usr/local/bin/phpshow').with(
      path: '/usr/local/bin/phpshow',
      source: 'phpshow',
      mode: '755',
      cookbook: 'osl-php'
    )

    is_expected.to_not add_osl_repos_centos('default')
    is_expected.to_not add_osl_repos_alma('default')
  end

  context 'Using IUS' do
    cached(:subject) { chef_run }
    recipe do
      osl_php_install 'defaults with ius' do
        use_ius true
      end
    end

    it do
      is_expected.to_not include_recipe('yum-ius')
    end
  end

  context 'Using OPcache' do
    cached(:subject) { chef_run }
    recipe do
      osl_php_install 'defaults with opcache' do
        use_opcache true
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
      is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-cli php-pear php-opcache))
    end

    context 'OPCache with conf' do
      cached(:subject) { chef_run }
      recipe do
        osl_php_install 'defaults with opcache conf' do
          use_opcache true
          opcache_conf(
            'opcache.memory_consumption' => 256,
            'opcache.enable_cli' => 1,
            'opcache.taco salad' => 'without the shell, please.'
          )
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
      cached(:subject) { chef_run }
      recipe do
        osl_php_install 'fail opcache' do
          use_opcache true
          version '5.4'
        end
      end

      it do
        expect { chef_run }.to raise_error(RuntimeError, /Must use PHP >= 5.5 to use OPcache./)
      end
    end
  end

  context 'Composer' do
    cached(:subject) { chef_run }
    recipe do
      osl_php_install 'defaults with composer' do
        use_composer true
      end
    end
    it do
      is_expected.to create_if_missing_remote_file('/usr/local/bin/composer').with(
        source: 'https://getcomposer.org/download/2.2.18/composer.phar',
        mode: '755'
      )
    end

    context 'Composer version' do
      cached(:subject) { chef_run }
      recipe do
        osl_php_install 'defaults with composer version' do
          use_composer true
          composer_version '2.2.17'
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
    cached(:subject) { chef_run }
    platform 'centos', '7'
    it do
      is_expected.to add_osl_repos_epel('default').with(exclude: %w(php73* php74*))
      is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-cli php-pear))
      # Don't install php-pear twice since it's already part of default packages
      is_expected.to_not install_package('php-pear')
    end

    context 'Using IUS' do
      cached(:subject) { chef_run }
      recipe do
        osl_php_install 'defaults with ius' do
          use_ius true
        end
      end
      it do
        is_expected.to add_osl_repos_centos('default').with(exclude: []) # version = 7.4
        is_expected.to create_yum_repository('osuosl')
        is_expected.to include_recipe('yum-ius')
        is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-cli php-pear))
      end
    end

    context 'Using OPCache' do
      cached(:subject) { chef_run }
      recipe do
        osl_php_install 'defaults with opcache' do
          use_opcache true
          use_ius true
        end
      end
      it do
        is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-cli php-pear php74-opcache))
      end

      context 'Fail OPcache due to no IUS' do
        cached(:subject) { chef_run }
        recipe do
          osl_php_install 'fail opcache' do
            use_opcache true
          end
        end

        it do
          expect { chef_run }.to raise_error(RuntimeError, /Must use PHP >= 5.5 with IUS enabled to use OPcache./)
        end
      end
    end
  end

  context 'using packages without prefixes' do
    cached(:subject) { chef_run }
    recipe do
      osl_php_install 'packages' do
        packages %w(graphviz-php pecl-imagick php-cli)
      end
    end

    it do
      is_expected.to install_php_install('all-packages').with(packages: %w(graphviz-php php-cli php))
      is_expected.to_not install_package('pecl-imagick')
      is_expected.to install_package('php-pear')
      is_expected.not_to install_package(%w(php-graphviz-php php-pecl-imagick php-php-cli php-devel))
    end

    context 'Using OPcache' do
      cached(:subject) { chef_run }
      recipe do
        osl_php_install 'non-prefixed packages with opcache' do
          packages %w(graphviz-php pecl-imagick php-cli)
          use_opcache true
        end
      end
      it do
        is_expected.to install_php_install('all-packages').with(packages: %w(graphviz-php php-cli php php-opcache))
      end
    end

    context 'CentOS 7' do
      cached(:subject) { chef_run }
      platform 'centos', '7'

      recipe do
        osl_php_install 'packages' do
          packages %w(graphviz-php pecl-imagick php-cli)
        end
      end

      it do
        is_expected.to install_php_install('all-packages').with(packages: %w(graphviz-php pecl-imagick php-cli php))
        is_expected.to install_package('php-pear')
        is_expected.not_to install_package(%w(php-graphviz-php php-pecl-imagick php-php-cli php-devel))
      end

      context 'Using OPcache' do
        cached(:subject) { chef_run }
        recipe do
          osl_php_install 'non-prefixed packages with opcache' do
            packages %w(graphviz-php pecl-imagick php-cli)
            use_ius true
            use_opcache true
          end
        end
        it do
          is_expected.to install_php_install('all-packages').with(packages: %w(graphviz-php pecl-imagick php-cli mod_php74 php74-opcache))
        end
      end
    end
  end

  %w(5.6 7.2 7.4).each do |version|
    context "using packages with versioned prefixes: php #{version}" do
      cached(:subject) { chef_run }
      platform 'almalinux', '8'

      recipe do
        osl_php_install 'packages' do
          packages []
          php_packages %w(devel)
          version version
        end
      end

      it do
        if version == '7.2'
          is_expected.to add_osl_repos_epel('default').with(exclude: %w(php73* php74*))
        else
          is_expected.to add_osl_repos_epel('default').with(exclude: [])
        end

        is_expected.to add_osl_repos_alma('default')
        case version
        when '5.6'
          is_expected.to create_yum_remi_php56('default')
        when '7.2'
          is_expected.to create_yum_remi_php72('default')
        when '7.4'
          is_expected.to create_yum_remi_php74('default')
        end

        is_expected.to install_php_install('all-packages').with(packages: %w(php-devel php))
        is_expected.to install_package('php-pear')
        is_expected.to_not install_package(%w(pecl-imagick php-cli))
      end

      context 'CentOS 7' do
        cached(:subject) { chef_run }
        platform 'centos', '7'
        recipe do
          osl_php_install 'packages' do
            php_packages %w(devel)
            version version
          end
        end

        it do
          if version.to_i >= 7
            is_expected.to install_php_install('all-packages').with(packages: %w(php-devel mod_php))
            is_expected.to install_package('pear1')
          else
            is_expected.to install_php_install('all-packages').with(packages: %w(php-devel php))
            is_expected.to install_package('php-pear')
          end

          is_expected.to_not install_package('pecl-imagick php-cli')
        end

        context 'Using IUS' do
          cached(:subject) { chef_run }
          recipe do
            osl_php_install 'packages' do
              php_packages %w(devel)
              version version
              use_ius true
            end
          end
          it do
            prefix = "php#{version.delete('.')}#{version.to_f < 7.3 ? 'u' : ''}"

            is_expected.to add_osl_repos_centos('default').with(exclude: %w(ImageMagick*)) if version.to_f <= 7.1
            is_expected.to add_osl_repos_centos('default').with(exclude: []) if version.to_f > 7.1

            is_expected.to include_recipe('yum-ius')

            if version.to_f >= 7
              is_expected.to install_php_install('all-packages').with(packages: ["#{prefix}-devel", "mod_#{prefix}"])
              is_expected.to install_package('pear1')
            else
              is_expected.to install_php_install('all-packages').with(packages: ["#{prefix}-devel", "#{prefix}"])
              is_expected.to install_package("#{prefix}-pear")
            end
          end
        end

        context 'Using OPcache' do
          cached(:subject) { chef_run }
          recipe do
            osl_php_install 'packages' do
              php_packages %w(devel)
              version version
              use_ius true
              use_opcache true
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

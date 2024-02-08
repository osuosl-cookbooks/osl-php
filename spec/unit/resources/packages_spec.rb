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
    is_expected.to add_osl_repos_epel('default')

    is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-cli php-pear))
    is_expected.to_not install_package('php-pear')
    is_expected.to_not add_osl_php_ini('10-opcache')
    # TODO: convert this recipe include to resources

    is_expected.to_not add_osl_repos_centos('default')
    is_expected.to_not add_osl_repos_alma('default')

    # TODO: this should be in an integration test, not here
    # %w(pear1 mod_php opcache pecl-imagick).each do |p|
    # is_expected.to_not install_package(p)
    # end
    # is_expected.to add_osl_php_ini
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

  context 'CentOS 7' do
    cached(:subject) { chef_run }
    platform 'centos', '7'
    it do
      is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-cli php-pear))
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
        # TODO: add others
        is_expected.to_not include_recipe('yum-centos') # version = 7.4
        is_expected.to include_recipe('yum-ius')
      end
    end
  end

  context 'using packages without prefixes' do
    cached(:subject) { chef_run }

    recipe do
      osl_php_install 'packages' do
        packages %w(graphviz-php pecl-imagick)
      end
    end

    it do
      is_expected.to install_php_install('all-packages').with(packages: %w(graphviz-php php))
      is_expected.to install_package('php-pear')
      is_expected.not_to install_package(%w(php-graphviz-php pecl-imagick php-cli php-devel))
    end

    context 'CentOS 7' do
      cached(:subject) { chef_run }
      platform 'centos', '7'

      recipe do
        osl_php_install 'packages' do
          packages %w(graphviz-php pecl-imagick)
        end
      end

      it do
        is_expected.to install_php_install('all-packages').with(packages: %w(graphviz-php pecl-imagick php))
        is_expected.to install_package('php-pear')
        is_expected.not_to install_package(%w(php-cli php-devel))
      end

      context 'using IUS' do
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

      prefix = 'php'

      it do
        is_expected.to install_php_install('all-packages').with(packages: ["#{prefix}-devel", 'php'])
        is_expected.to install_package("#{prefix}-pear")
        is_expected.to_not install_package(%w(pecl-imagick php-cli))
      end

      context 'CentOS 7' do
        cached(:subject) { chef_run }
        platform 'centos', '7'

        recipe do
          osl_php_install 'packages' do
            packages []
            php_packages %w(devel)
            version version
          end
        end

        prefix = 'php'
        # prefix = "php#{version.delete('.')}#{version.to_f < 7.3 ? 'u' : ''}"

        it do
          if version.to_i == 7
            is_expected.to install_php_install('all-packages').with(packages: ["#{prefix}-devel", 'mod_php'])
            is_expected.to install_package('pear1')
          else
            is_expected.to install_php_install('all-packages').with(packages: ["#{prefix}-devel", 'php'])
            is_expected.to install_package("#{prefix}-pear")
          end

          is_expected.to_not install_package("pecl-imagick #{prefix}-php-cli")
        end

        context 'Using IUS' do
          cached(:subject) { chef_run }
          recipe do
            osl_php_install 'packages' do
              packages []
              php_packages %w(devel)
              version version
              use_ius true
            end
          end
          it do
            # TODO: add others
            is_expected.to include_recipe('yum-ius')
            is_expected.to include_recipe('yum-centos') if
              version.to_i == 7 \
              && version.to_f <= 7.1 \
              && ius_archive_versions.include?(version)
          end
        end
      end
    end
  end
end

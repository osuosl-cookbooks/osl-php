require_relative '../../spec_helper'

describe 'osl_php_install' do
  platform 'almalinux', '8'
  cached(:subject) { chef_run }
  step_into :osl_php_install

  recipe do
    osl_php_install 'default packages'
  end

  it do
    is_expected.to install_selinux_install('osl-selinux')
    is_expected.to enforcing_selinux_state('osl-selinux')
    is_expected.to add_osl_repos_epel('default')

    is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-cli php-pear))
    is_expected.to_not add_osl_php_ini('10-opcache')
    # TODO: convert this recipe include to resources
    is_expected.to_not include_recipe('osl-repos::centos')
    is_expected.to_not add_osl_repos_centos('default')
    is_expected.to_not add_osl_repos_alma('default')

    # TODO: this should be in an integration test, not here
    # %w(pear1 mod_php opcache pecl-imagick).each do |p|
    # is_expected.to_not install_package(p)
    # end
    # is_expected.to add_osl_php_ini
  end

  context 'CentOS 7' do
    platform 'centos', '7'
    it do
      is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-cli php-pear))
    end
  end

  context 'packages' do
    recipe do
      osl_php_install 'packages' do
        packages %w(php-devel)
      end
    end

    it do
      is_expected.to install_php_install('all-packages').with(packages: %w(php php-devel php-pear))
      is_expected.not_to install_package('php-cli')
    end
  end

  %w(5.6 7.2 7.4).each do |version|
    context "using php #{version}" do
      prefix = 'php'
      context 'using packages with versioned prefixes' do
        recipe do
        end

        context 'CentOS 7' do
          prefix = "php#{version.delete('.')}#{version.to_f < 7.3 ? 'u' : ''}"
        end

      end
    end
  end
end
#                 node['version'] = version
#                 node['use_ius'] = true
#                 node['php_packages'] = %w(devel cli)

#             end
#             it 'converges successfully' do
#               expect { chef_run }.to_not raise_error
#             end
#             it do
#               php_pkg =
#                 case pltfrm
#                 when ALMA_8
#                   prefix
#                 else
#                   version.to_f < 7 ? prefix : "mod_#{prefix}"
#                 end
#               expect(chef_run).to install_package(
#                 "#{prefix}-devel, #{prefix}-cli, #{php_pkg}"
#               )
#             end
#             it do
#               expect(chef_run).to install_package('pear')
#             end
#             it do
#               case pltfrm
#               when ALMA_8
#                 expect(chef_run).to_not create_yum_repository('ius')
#               else
#                 case version
#                 when '7.2'
#                   expect(chef_run).to create_yum_repository('ius').with(exclude: 'php73* php74*')
#                 else
#                   expect(chef_run).to_not create_yum_repository('ius').with(exclude: 'php73*')
#                 end
#               end
#             end
#             it do
#               case pltfrm
#               when ALMA_8
#                 expect(chef_run).to_not create_yum_repository('ius-archive')
#               when CENTOS_7
#                 case version
#                 when '5.6', '7.2', '7.4'
#                   expect(chef_run).to create_yum_repository('ius-archive').with(enabled: true)
#                 else
#                   expect(chef_run).to create_yum_repository('ius-archive').with(enabled: false)
#                 end
#               end
#             end
#             case pltfrm
#             when CENTOS_7
#               it do
#                 expect(chef_run).to include_recipe('osl-repos::centos')
#               end
#               it do
#                 expect(chef_run).to include_recipe('yum-osuosl')
#               end
#               case version
#               when '5.6'
#                 it do
#                   expect(chef_run).to create_yum_repository('base').with(exclude: 'ImageMagick*')
#                 end
#               else
#                 it do
#                   expect(chef_run).to_not create_yum_repository('base').with(exclude: 'ImageMagick*')
#                 end
#               end
#             when ALMA_8
#               next if version.to_f < 7.2
#               shortver = version.to_s.delete('.')
#               it { is_expected.to add_osl_repos_alma('default') }
#               it { is_expected.to send(:"create_yum_remi_php#{shortver}", 'default') }
#             end
#           end
#           context 'old method for backwards compatability' do
#             cached(:chef_run) do
#               ChefSpec::SoloRunner.new(pltfrm.dup.merge(step_into: %w(osl_php_install))) do |node|
#                 node['version'] = version
#                 node['packages'] = %w(devel cli).map { |p| "#{prefix}-#{p}" }
#               end.converge(described_recipe)
#             end
#             it 'converges successfully' do
#               expect { chef_run }.to_not raise_error
#             end
#             it do
#               php_pkg =
#                 case pltfrm
#                 when ALMA_8
#                   prefix
#                 when CENTOS_7
#                   version.to_f < 7 ? prefix : "mod_#{prefix}"
#                 end
#               expect(chef_run).to install_package(
#                 "#{prefix}-devel, #{prefix}-cli, #{php_pkg}"
#               )
#             end
#             it do
#               expect(chef_run).to install_package('pear')
#             end
#             it do
#               case pltfrm
#               when ALMA_8
#                 expect(chef_run).to_not create_yum_repository('ius')
#               when CENTOS_7
#                 if version == '7.2'
#                   expect(chef_run).to create_yum_repository('ius').with(exclude: 'php73* php74*')
#                 else
#                   expect(chef_run).to_not create_yum_repository('ius').with(
#                     exclude: 'php73*'
#                   )
#                 end
#               end
#             end
#           end
#         end
#       end
#     end
#   end
# end

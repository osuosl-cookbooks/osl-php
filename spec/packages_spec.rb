require_relative 'spec_helper'

describe 'osl-php::packages' do
  ALL_PLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      context 'using packages with non-versioned prefixes' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.normal['osl-php']['php_packages'] = %w(devel cli)
          end.converge(described_recipe)
        end
        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end
        it do
          expect(chef_run).to install_package(
            'php-devel, php-cli, php'
          )
        end
        it do
          expect(chef_run).to install_package('php-pear')
        end
        %w(osl-selinux::default).each do |r|
          it do
            expect(chef_run).to include_recipe(r)
          end
        end
      end
      %w(5.6 7.1 7.2 7.3 7.4).each do |php_version|
        prefix =
          case pltfrm
          when CENTOS_7
            "php#{php_version.split('.').join}#{php_version.to_f < 7.3 ? 'u' : ''}"
          when CENTOS_8
            'php'
          end
        context "using php #{php_version}" do
          context 'using packages with versioned prefixes' do
            cached(:chef_run) do
              ChefSpec::SoloRunner.new(pltfrm) do |node|
                node.normal['php']['version'] = php_version
                node.normal['osl-php']['use_ius'] = true
                node.normal['osl-php']['php_packages'] = %w(devel cli)
              end.converge(described_recipe)
            end
            it 'converges successfully' do
              expect { chef_run }.to_not raise_error
            end
            it do
              php_pkg =
                case pltfrm
                when CENTOS_8
                  'php'
                else
                  php_version.to_f < 7 ? prefix : "mod_#{prefix}"
                end
              expect(chef_run).to install_package(
                "#{prefix}-devel, #{prefix}-cli, #{php_pkg}"
              )
            end
            it do
              expect(chef_run).to install_package('pear')
            end
            it do
              if pltfrm == CENTOS_8
                expect(chef_run).to_not create_yum_repository('ius')
              else
                case php_version
                when '7.2'
                  expect(chef_run).to create_yum_repository('ius').with(exclude: 'php73* php74*')
                when '7.3'
                  expect(chef_run).to create_yum_repository('ius').with(exclude: 'php74*')
                else
                  expect(chef_run).to_not create_yum_repository('ius').with(exclude: 'php73*')
                end
              end
            end
            it do
              if pltfrm == CENTOS_8
                expect(chef_run).to_not create_yum_repository('ius-archive')
              else
                case php_version
                when '5.6', '7.1', '7.2'
                  expect(chef_run).to create_yum_repository('ius-archive').with(enabled: true)
                else
                  expect(chef_run).to create_yum_repository('ius-archive').with(enabled: false)
                end
              end
            end
            if pltfrm == CENTOS_7
              it do
                expect(chef_run).to include_recipe('osl-repos::centos')
              end
              it do
                expect(chef_run).to include_recipe('yum-osuosl')
              end
              case php_version
              when '5.6', '7.1'
                it do
                  expect(chef_run).to create_yum_repository('base').with(exclude: 'ImageMagick*')
                end
              else
                it do
                  expect(chef_run).to_not create_yum_repository('base').with(exclude: 'ImageMagick*')
                end
              end
            else
              it do
                expect(chef_run).to_not include_recipe('yum-centos')
              end
              it do
                expect(chef_run).to_not include_recipe('yum-osuosl')
              end
              it do
                expect(chef_run).to_not create_yum_repository('base').with(exclude: 'ImageMagick*')
              end
            end
          end
          context 'old method for backwards compatability' do
            cached(:chef_run) do
              ChefSpec::SoloRunner.new(pltfrm) do |node|
                node.normal['php']['version'] = php_version
                node.normal['osl-php']['use_ius'] = true
                node.normal['osl-php']['packages'] =
                  %w(devel cli).map { |p| "#{prefix}-#{p}" }
              end.converge(described_recipe)
            end
            it 'converges successfully' do
              expect { chef_run }.to_not raise_error
            end
            it do
              php_pkg =
                if pltfrm == CENTOS_8
                  'php'
                else
                  php_version.to_f < 7 ? prefix : "mod_#{prefix}"
                end
              expect(chef_run).to install_package(
                "#{prefix}-devel, #{prefix}-cli, #{php_pkg}"
              )
            end
            it do
              expect(chef_run).to install_package('pear')
            end
            it do
              if pltfrm == CENTOS_8
                expect(chef_run).to_not create_yum_repository('ius')
              elsif php_version == '7.2'
                expect(chef_run).to create_yum_repository('ius').with(exclude: 'php73* php74*')
              elsif php_version == '7.3'
                expect(chef_run).to create_yum_repository('ius').with(exclude: 'php74*')
              else
                expect(chef_run).to_not create_yum_repository('ius').with(
                  exclude: 'php73*'
                )
              end
            end
          end
        end
      end
    end
  end
end

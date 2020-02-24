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
      end
      %w(5.3 5.6 7.1 7.2 7.3).each do |php_version|
        prefix =
          case pltfrm
          when CENTOS_6, CENTOS_7
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
                when '5.3'
                  if pltfrm[:version].to_i >= 7 && pltfrm[:version].to_i < 8
                    expect(chef_run).to create_yum_repository('ius')
                      .with(
                        gpgkey: 'http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl',
                        baseurl: 'http://ftp.osuosl.org/pub/osl/repos/yum/$releasever/php53/$basearch',
                        mirrorlist: nil
                      )
                  else
                    expect(chef_run).to_not create_yum_repository('ius')
                      .with(
                        gpgkey: 'http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl',
                        baseurl: 'http://ftp.osuosl.org/pub/osl/repos/yum/$releasever/php53/$basearch',
                        mirrorlist: nil
                      )
                  end
                when '7.1'
                  expect(chef_run).to create_yum_repository('ius').with(exclude: 'php72* php73*')
                when '7.2'
                  expect(chef_run).to create_yum_repository('ius').with(exclude: 'php73*')
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
                when '5.3', '5.6', '7.0'
                  expect(chef_run).to create_yum_repository('ius-archive')
                else
                  expect(chef_run).to_not create_yum_repository('ius-archive')
                end
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
              elsif php_version == '7.1'
                expect(chef_run).to create_yum_repository('ius').with(
                  exclude: 'php72* php73*'
                )
              elsif php_version == '7.2'
                expect(chef_run).to create_yum_repository('ius').with(exclude: 'php73*')
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

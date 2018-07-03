require_relative 'spec_helper'

describe 'osl-php::packages' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS].each do |pltfrm|
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
      %w(7.1 7.2).each do |version|
        prefix = "php#{version.split('.').join}u"
        context "using php #{version}" do
          context 'using packages with versioned prefixes' do
            cached(:chef_run) do
              ChefSpec::SoloRunner.new(pltfrm) do |node|
                node.normal['php']['version'] = version
                node.normal['osl-php']['use_ius'] = true
                node.normal['osl-php']['php_packages'] = %w(devel cli)
              end.converge(described_recipe)
            end
            it 'converges successfully' do
              expect { chef_run }.to_not raise_error
            end
            it do
              expect(chef_run).to install_package(
                "#{prefix}-devel, #{prefix}-cli, #{prefix}"
              )
            end
            it do
              expect(chef_run).to install_package('pear')
            end
            it do
              if version == '7.1'
                expect(chef_run).to create_yum_repository('ius').with(
                  exclude: 'php72*'
                )
              else
                expect(chef_run).to_not create_yum_repository('ius').with(
                  exclude: 'php72*'
                )
              end
            end
          end
          context 'old method for backwards compatability' do
            cached(:chef_run) do
              ChefSpec::SoloRunner.new(pltfrm) do |node|
                node.normal['php']['version'] = version
                node.normal['osl-php']['use_ius'] = true
                node.normal['osl-php']['packages'] =
                  %w(devel cli).map { |p| "#{prefix}-#{p}" }
              end.converge(described_recipe)
            end
            it 'converges successfully' do
              expect { chef_run }.to_not raise_error
            end
            it do
              expect(chef_run).to install_package(
                "#{prefix}-devel, #{prefix}-cli, #{prefix}"
              )
            end
            it do
              expect(chef_run).to install_package('pear')
            end
            it do
              if version == '7.1'
                expect(chef_run).to create_yum_repository('ius').with(
                  exclude: 'php72*'
                )
              else
                expect(chef_run).to_not create_yum_repository('ius').with(
                  exclude: 'php72*'
                )
              end
            end
          end
        end
      end
    end
  end
end

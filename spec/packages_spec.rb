require_relative 'spec_helper'

describe 'osl-php::packages' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS].each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      context 'using packages with non-versioned prefixes' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.set['osl-php']['php_packages'] = %w(devel cli)
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

      context 'using packages with versioned prefixes' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.set['php']['version'] = '7.1'
            node.set['osl-php']['use_ius'] = true
            node.set['osl-php']['php_packages'] = %w(devel cli)
          end.converge(described_recipe)
        end
        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end
        it do
          expect(chef_run).to install_package(
            'php71u-devel, php71u-cli, php71u'
          )
        end
        it do
          expect(chef_run).to install_package('pear1u')
        end
      end
      context 'old method for backwards compatability' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.set['php']['version'] = '7.1'
            node.set['osl-php']['use_ius'] = true
            node.set['osl-php']['packages'] =
              %w(php71u-devel php71u-cli)
          end.converge(described_recipe)
        end
        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end
        it do
          expect(chef_run).to install_package(
            'php71u-devel, php71u-cli, php71u'
          )
        end
        it do
          expect(chef_run).to install_package('pear1u')
        end
      end
    end
  end
end

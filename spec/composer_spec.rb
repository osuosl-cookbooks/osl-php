require_relative 'spec_helper'

describe 'osl-php::composer' do
  ALL_PLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it 'converges successfully' do
        stub_command("php -m | grep 'Phar'").and_return(false)
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run.node['composer']['url']).to eq('https://getcomposer.org/download/1.2.1/composer.phar')
      end
      %w(php::default composer::default).each do |r|
        it do
          expect(chef_run).to include_recipe(r)
        end
      end
      context 'install different version' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.normal['osl-php']['composer_version'] = '1.9.1'
          end.converge(described_recipe)
        end
        it 'converges successfully' do
          stub_command("php -m | grep 'Phar'").and_return(false)
          expect { chef_run }.to_not raise_error
        end
        it do
          expect(chef_run.node['composer']['url']).to eq('https://getcomposer.org/download/1.9.1/composer.phar')
        end
      end
    end
  end
end

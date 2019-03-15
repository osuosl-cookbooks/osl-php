require_relative 'spec_helper'

describe 'osl-php::default' do
  ALL_PLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      %w(osl-php::packages php::default).each do |r|
        it do
          expect(chef_run).to include_recipe(r)
        end
      end
      it do
        expect(chef_run).to_not include_recipe('osl-php::opcache')
      end
    end
  end
  ALL_PLATFORMS.each do |pltfrm|
    ['5.4', '5.6', '7.2'].each do |php_v|
      [false, true].each do |use_opcache|
        description = "php v#{php_v} and #{'no ' unless use_opcache}opcache"

        context "on #{pltfrm[:platform]} #{pltfrm[:version]} with #{description}" do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(pltfrm) do |node|
              node.normal['php']['version'] = php_v
              node.normal['osl-php'].merge!(
                'use_opcache' => use_opcache,
                'php_packages' => []
              )
            end.converge(described_recipe)
          end

          if use_opcache && php_v.to_f < 5.5
            it 'fails to converge' do
              expect { chef_run }.to raise_error RuntimeError
            end
          elsif use_opcache
            it 'converges successfully' do
              expect { chef_run }.to_not raise_error
            end
            %w(osl-php::packages php::default osl-php::opcache).each do |r|
              it do
                expect(chef_run).to include_recipe r
              end
            end
            it do
              expect(chef_run).to add_php_ini('10-opcache')
            end
            it do
              expect(chef_run).to_not include_recipe 'osl-php::opcache' unless use_opcache
            end
          end
        end
      end
    end
  end
end

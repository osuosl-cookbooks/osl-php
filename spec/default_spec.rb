require_relative 'spec_helper'

describe 'osl-php::default' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS].each do |pltfrm|
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
    end
  end
end

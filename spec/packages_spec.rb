require_relative 'spec_helper'

describe 'osl-php::packages' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS, DEBIAN_8_OPTS].each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      before do
        chef_run.node.set['osl-php']['packages'] = 'php-gd'
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
    end
  end
end

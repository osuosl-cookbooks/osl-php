require_relative 'spec_helper'

describe 'osl-php::composer' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS].each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it 'converges successfully' do
        stub_command("php -m | grep 'Phar'").and_return(false)
        expect { chef_run }.to_not raise_error
      end
      it 'Includes composer default recipe' do
        expect(chef_run).to include_recipe('composer::default')
      end
    end
  end
end
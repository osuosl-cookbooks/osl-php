require_relative 'spec_helper'

describe 'osl-php::packages' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS].each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm) do |node|
          node.set['osl-php']['packages'] = %w(php
                                               php-devel
                                               php-fpm
                                               php-gd
                                               php-pear)
        end.converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to install_package(
          chef_run.node['osl-php']['packages']
        )
      end
    end
  end
end

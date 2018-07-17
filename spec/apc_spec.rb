require_relative 'spec_helper'

describe 'osl-php::apc' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS].each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      before do
        chef_run.node.normal['osl-php']['apc']['shm_size'] = '64M'
        chef_run.node.normal['osl-php']['apc']['enable_cli'] = 0
        chef_run.node.normal['osl-php']['apc']['ttl'] = 3600
        chef_run.node.normal['osl-php']['apc']['user_ttl'] = 7200
        chef_run.node.normal['osl-php']['apc']['gc_ttl'] = 3600
        chef_run.node.normal['osl-php']['apc']['max_file_size'] = '1M'
        chef_run.node.normal['osl-php']['apc']['stat'] = 1
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      %w(httpd-devel pcre pcre-devel).each do |pkg|
        it do
          expect(chef_run).to install_package(pkg)
        end
      end
      it do
        expect(chef_run). to install_php_pear('APC')
      end
      it do
        expect(chef_run).to include_recipe('build-essential')
      end
      it do
        expect(chef_run).to create_directory('/etc/php.d')
      end
      it do
        expect(chef_run).to create_template('/etc/php.d/APC.ini').with(
          source: 'apc.ini.erb',
          owner: 'root',
          group: 'root',
          mode: '0644',
          variables: {
            params: chef_run.node['osl-php']['apc'],
          }
        )
      end
      context 'node[\'osl-php\'][\'use_ius\'] set to true' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.normal['osl-php']['use_ius'] = true
          end.converge(described_recipe)
        end
        it do
          expect(chef_run).to run_ruby_block('raise_use_ius_exception')
        end
      end
    end
  end
end

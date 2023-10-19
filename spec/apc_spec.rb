require_relative 'spec_helper'

describe 'osl-php::apc' do
  ALL_PLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      before do
        # chef_run.node.default['osl-php']['apc']['apc.shm_size'] = '64M'
        # chef_run.node.default['osl-php']['apc']['apc.enable_cli'] = 0
        # chef_run.node.default['osl-php']['apc']['apc.ttl'] = 3600
        # chef_run.node.default['osl-php']['apc']['apc.user_ttl'] = 7200
        # chef_run.node.default['osl-php']['apc']['apc.gc_ttl'] = 3600
        # chef_run.node.default['osl-php']['apc']['apc.max_file_size'] = '1M'
        # chef_run.node.default['osl-php']['apc']['apc.stat'] = 1
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      %w(osl-selinux::default).each do |r|
        it do
          expect(chef_run).to include_recipe(r)
        end
      end
      case pltfrm
      when ALMA_8
        it do
          expect(chef_run).to run_ruby_block('raise_el8_exception')
        end
      else
        %w(httpd-devel pcre pcre-devel).each do |pkg|
          it do
            expect(chef_run).to install_package(pkg)
          end
        end
        it do
          expect(chef_run). to install_php_pear('APC')
        end
        it do
          expect(chef_run).to install_build_essential('APC')
        end
        it do
          expect(chef_run).to add_php_ini('APC').with(
            options: {
              'extension' => 'apc.so',
              'apc.shm_size' => '128M',
              'apc.enable_cli' => 0,
              'apc.ttl' => 3600,
              'apc.user_ttl' => 7200,
              'apc.gc_ttl' => 3600,
              'apc.max_file_size' => '1M',
              'apc.stat' => 1,
            }
          )
        end
        context 'node[\'osl-php\'][\'use_ius\'] set to true' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(pltfrm) do |node|
              node.override['osl-php']['use_ius'] = true
            end.converge(described_recipe)
          end
          it do
            expect(chef_run).to run_ruby_block('raise_use_ius_exception')
          end
        end
      end
    end
  end
end

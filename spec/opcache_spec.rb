require_relative 'spec_helper'

describe 'osl-php::opcache' do
  [CENTOS_7_OPTS].each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm) do |node|
          node.normal['osl-php']['use_opcache'] = true
          node.normal['osl-php']['opcache'] = {
            'opcache.enable' => '1',
            'opcache.enable_cli' => '1',
            'opcache.taco salad' => 'without the shell, please.',
          }
        end.converge(described_recipe)
      end
      it do
        expect(chef_run).to add_php_ini('10-opcache').with(
          options: {
            'opcache.blacklist_filename' => '/etc/php.d/opcache*.blacklist',
            'opcache.enable' => '1',
            'opcache.enable_cli' => '1',
            'opcache.taco salad' => 'without the shell, please.',
            'opcache.huge_code_pages' => 0,
            'opcache.interned_strings_buffer' => 8,
            'opcache.max_accelerated_files' => 4000,
            'opcache.memory_consumption' => 128,
            'zend_extension' => 'opcache.so',
          }
        )
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
    end
  end
end

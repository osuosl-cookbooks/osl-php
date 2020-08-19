require 'spec_helper'

describe 'php_test::php_ini' do
  ALL_PLATFORMS.each do |p|
    context "on platform #{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          p.dup.merge(step_into: %w(php_ini))
        ).converge(described_recipe)
      end

      %w(
        no_sections_rendered
        with_sections_rendered
        no_sections_rendered_added
      ).each do |name|
        it do
          expect(chef_run).to create_directory("/etc/php.d #{name}").with(path: '/etc/php.d')
        end
        it do
          expect(chef_run).to add_php_ini name
        end
        it do
          expect(chef_run).to create_template("/etc/php.d/#{name}.ini").with(
            source: 'php_ini.erb',
            cookbook: 'osl-php',
            mode: '0644'
          )
        end
      end

      it do
        expect(chef_run).to remove_php_ini('no_sections_rendered_removed')
      end

      it do
        expect(chef_run).to delete_file '/etc/php.d/no_sections_rendered_removed.ini'
      end
    end
  end
end

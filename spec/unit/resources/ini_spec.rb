require_relative '../../spec_helper'

describe 'osl_php_ini' do
  cached(:subject) { chef_run }
  platform 'almalinux', '8'
  step_into :osl_php_ini

  recipe do
    osl_php_ini 'default' do
      options data: { 'test' => 'test' }
    end
  end

  it { is_expected.to add_osl_php_ini('default').with(options: { data: { 'test' => 'test' } }) }
  it { is_expected.to create_directory('/etc/php.d default').with(path: '/etc/php.d') }

  it do
    is_expected.to create_template('/etc/php.d/default.ini').with(
      source: 'php_ini.erb',
      cookbook: 'osl-php',
      mode: '0644'
    )
  end

  context 'options' do
    cached(:subject) { chef_run }

    with_sections = {
      'key' => 'value',
      'section' => {
        'section_key' => 'section_value',
      },
    }

    no_sections = {
      'key' => 'value',
      'section_key' => 'section_value',
    }

    recipe do
      osl_php_ini 'with_sections' do
        options with_sections
      end
      osl_php_ini 'no_sections' do
        options no_sections
      end
    end

    it { is_expected.to create_template('/etc/php.d/with_sections.ini').with(variables: { data: with_sections }) }
  end

  context 'Remove ini' do
    cached(:subject) { chef_run }

    recipe do
      osl_php_ini 'remove' do
        action :remove
      end
    end

    it { is_expected.to delete_file('/etc/php.d/remove.ini') }
  end
end

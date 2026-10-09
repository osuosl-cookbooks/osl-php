require_relative '../../spec_helper'

describe 'osl_php_ini' do
  cached(:subject) { chef_run }
  platform 'almalinux'
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
  it { is_expected.to nothing_notify_group('osl-php restart') }
  it { expect(subject.template('/etc/php.d/default.ini')).to notify('notify_group[osl-php restart]').to(:run).delayed }

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

  context 'config_dir' do
    cached(:subject) { chef_run }

    recipe do
      osl_php_ini 'web' do
        options('key' => 'value')
        config_dir '/etc/php-web.d'
        php_version '8.4'
      end
    end

    it { is_expected.to create_directory('/etc/php-web.d web').with(path: '/etc/php-web.d') }
    it { is_expected.to create_template('/etc/php-web.d/web.ini') }
    it { is_expected.to_not create_template('/etc/opt/remi/php84/php.d/web.ini') }
  end

  context 'Remove ini' do
    cached(:subject) { chef_run }

    recipe do
      osl_php_ini 'remove' do
        action :remove
      end
    end

    it { is_expected.to delete_file('/etc/php.d/remove.ini') }
    it { expect(subject.file('/etc/php.d/remove.ini')).to notify('notify_group[osl-php restart]').to(:run).delayed }
  end

  context 'versioned php' do
    cached(:subject) { chef_run }

    recipe do
      osl_php_ini 'default' do
        options('date.timezone' => 'UTC')
        php_version '8.4'
      end
    end

    it { is_expected.to add_osl_php_ini('default').with(options: { 'date.timezone' => 'UTC' }, php_version: '8.4') }
    it { is_expected.to create_directory('/etc/opt/remi/php84/php.d default').with(path: '/etc/opt/remi/php84/php.d') }

    it do
      is_expected.to create_template('/etc/opt/remi/php84/php.d/default.ini').with(
        source: 'php_ini.erb',
        cookbook: 'osl-php',
        mode: '0644'
      )
    end
  end

  context 'versioned php remove' do
    cached(:subject) { chef_run }

    recipe do
      osl_php_ini 'remove' do
        php_version '8.4'
        action :remove
      end
    end

    it { is_expected.to delete_file('/etc/opt/remi/php84/php.d/remove.ini') }
  end
end

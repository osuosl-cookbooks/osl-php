require_relative '../../spec_helper'

describe 'osl_php_apc' do
  cached(:subject) { chef_run }
  platform 'centos', '7'
  step_into :osl_php_apc

  recipe do
    osl_php_apc 'default'
  end

  it do
    is_expected.to install_selinux_install('osl-selinux')
  end

  %w(httpd-devel pcre pcre-devel).each do |pkg|
    it do
      is_expected.to install_package(pkg)
    end
  end

  it do
    is_expected.to install_php_pear('APC')
    is_expected.to install_build_essential('APC')
    is_expected.to add_php_ini('APC').with(
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

  context 'options' do
    cached(:subject) { chef_run }

    recipe do
      osl_php_apc 'options' do
        options {
          'extension' => 'apc.so',
          'apc.shm_size' => '64M',
          'apc.enable_cli' => 1,
          'apc.ttl' => 7200,
          'apc.user_ttl' => 12800,
          'apc.gc_ttl' => 7200,
          'apc.max_file_size' => '4M',
          'apc.stat' => 0,
        }
      end
    end

    it do
      is_expected.to add_php_ini('APC').with(
        options: {
          'extension' => 'apc.so',
          'apc.shm_size' => '64M',
          'apc.enable_cli' => 1,
          'apc.ttl' => 7200,
          'apc.user_ttl' => 12800,
          'apc.gc_ttl' => 7200,
          'apc.max_file_size' => '4M',
          'apc.stat' => 0,
        }
      )
    end
  end

  context 'EL 8' do
    cached(:subject) { chef_run }
    platform 'almalinux', '8'
    it do
      is_expected.to run_ruby_block('raise_el8_exception')
    end
  end
end

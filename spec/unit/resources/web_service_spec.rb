require_relative '../../spec_helper'

describe 'osl_php_web_service' do
  cached(:subject) { chef_run }
  platform 'almalinux', '9'
  step_into :osl_php_web_service

  recipe do
    osl_php_web_service 'php-fpm'
  end

  it { is_expected.to create_osl_php_web_service('php-fpm') }
  it { is_expected.to nothing_service('php-fpm') }
  it { is_expected.to nothing_notify_group('osl-php restart') }

  it do
    is_expected.to create_osl_systemd_unit_drop_in('php-web-ini php-fpm.service').with(
      override_name: 'php-web-ini',
      unit_name: 'php-fpm.service',
      content: { 'Service' => { 'Environment' => 'PHP_INI_SCAN_DIR=:/etc/php-web.d' } }
    )
  end

  it do
    expect(subject.osl_systemd_unit_drop_in('php-web-ini php-fpm.service')).to \
      notify('service[php-fpm]').to(:restart).delayed
  end
  it { expect(subject.notify_group('osl-php restart')).to notify('service[php-fpm]').to(:reload).delayed }
  it { expect(subject.notify_group('osl-php restart')).to_not notify('service[php-fpm]').to(:restart) }

  context 'versioned php-fpm' do
    cached(:subject) { chef_run }

    recipe do
      osl_php_web_service 'php84-php-fpm'
    end

    it { is_expected.to create_osl_systemd_unit_drop_in('php-web-ini php84-php-fpm.service').with(unit_name: 'php84-php-fpm.service') }
    it { expect(subject.notify_group('osl-php restart')).to notify('service[php84-php-fpm]').to(:reload).delayed }
    it { is_expected.to_not nothing_service('php-fpm') }
  end

  context 'unit with a .service suffix' do
    recipe do
      osl_php_web_service 'php-fpm.service'
    end

    it { expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed) }
  end
end

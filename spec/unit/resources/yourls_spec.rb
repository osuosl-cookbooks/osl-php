require_relative '../../spec_helper'

describe 'osl_php_yourls' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p.merge(step_into: 'osl_php_yourls')).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to install_package 'tar' }

      it do
        is_expected.to put_ark('yourls').with(
          url: 'https://github.com/YOURLS/YOURLS/archive/refs/tags/1.10.2.tar.gz',
          path: '/var/www/resource_name/yourls'
          version: '1.10.2'
        )
      end

      it do
        is_expected.to create_template('/tmp/with_attributes').with(
          variables: {
            db_username: nil,
            db_password: nil,
            db_name: nil,
            db_host: nil,
            db_prefix: nil,
            domain: nil,
            language: '',
            unique_urls: true,
            private: true,
            cookiekey: nil,
            user_passwords: [],
            url_convert: 36,
            reserved_urls: [],
          }
        )
      end
    end
  end
end

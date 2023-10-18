require_relative 'spec_helper'

describe 'php_test::prefixed_packages' do
  ALL_PLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      context 'using packages with non-versioned prefixes' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
        end
        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end
        it do
          expect(chef_run).to install_package(
            'php-devel, php-cli, php'
          )
        end
        it do
          expect(chef_run).to install_package('php-pear')
        end
        %w(osl-selinux::default).each do |r|
          it do
            expect(chef_run).to include_recipe(r)
          end
        end
      end
    end
  end
end

describe 'php_test::unprefixed_packages' do
  ALL_PLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      %w(5.6 7.2 7.4).each do |version|
        prefix =
          case pltfrm
          when CENTOS_7
            "php#{version.delete('.')}#{version.to_f < 7.3 ? 'u' : ''}"
          when ALMA_8
            'php'
          end
        context "using php #{version}" do
          context 'using packages with versioned prefixes' do
            cached(:chef_run) do
              ChefSpec::SoloRunner.new(pltfrm) do |node|
                node['version'] = version
                node['use_ius'] = true
                node['unprefixed_names'] = %w(devel cli)
              end.converge(described_recipe)
            end
            it 'converges successfully' do
              expect { chef_run }.to_not raise_error
            end
            it do
              php_pkg =
                case pltfrm
                when ALMA_8
                  prefix
                else
                  version.to_f < 7 ? prefix : "mod_#{prefix}"
                end
              expect(chef_run).to install_package(
                "#{prefix}-devel, #{prefix}-cli, #{php_pkg}"
              )
            end
            it do
              expect(chef_run).to install_package('pear')
            end
            it do
              case pltfrm
              when ALMA_8
                expect(chef_run).to_not create_yum_repository('ius')
              else
                case php_version
                when '7.2'
                  expect(chef_run).to create_yum_repository('ius').with(exclude: 'php73* php74*')
                else
                  expect(chef_run).to_not create_yum_repository('ius').with(exclude: 'php73*')
                end
              end
            end
            it do
              case pltfrm
              when ALMA_8
                expect(chef_run).to_not create_yum_repository('ius-archive')
              when CENTOS_7
                case version
                when '5.6', '7.2', '7.4'
                  expect(chef_run).to create_yum_repository('ius-archive').with(enabled: true)
                else
                  expect(chef_run).to create_yum_repository('ius-archive').with(enabled: false)
                end
              end
            end
            case pltfrm
            when CENTOS_7
              it do
                expect(chef_run).to include_recipe('osl-repos::centos')
              end
              it do
                expect(chef_run).to include_recipe('yum-osuosl')
              end
              case php_version
              when '5.6'
                it do
                  expect(chef_run).to create_yum_repository('base').with(exclude: 'ImageMagick*')
                end
              else
                it do
                  expect(chef_run).to_not create_yum_repository('base').with(exclude: 'ImageMagick*')
                end
              end
            when ALMA_8
              next if php_version.to_f < 7.2
              shortver = php_version.to_s.delete('.')
              it { is_expected.to add_osl_repos_alma('default') }
              it { is_expected.to send(:"create_yum_remi_php#{shortver}", 'default') }
            end
          end
          context 'old method for backwards compatability' do
            cached(:chef_run) do
              ChefSpec::SoloRunner.new(pltfrm) do |node|
                node['version'] = version
                node['packages'] = %w(devel cli).map { |p| "#{prefix}-#{p}" }
              end.converge(described_recipe)
            end
            it 'converges successfully' do
              expect { chef_run }.to_not raise_error
            end
            it do
              php_pkg =
                case pltfrm
                when ALMA_8
                  prefix
                when CENTOS_7
                  php_version.to_f < 7 ? prefix : "mod_#{prefix}"
                end
              expect(chef_run).to install_package(
                "#{prefix}-devel, #{prefix}-cli, #{php_pkg}"
              )
            end
            it do
              expect(chef_run).to install_package('pear')
            end
            it do
              case pltfrm
              when ALMA_8
                expect(chef_run).to_not create_yum_repository('ius')
              when CENTOS_7
                if php_version == '7.2'
                  expect(chef_run).to create_yum_repository('ius').with(exclude: 'php73* php74*')
                else
                  expect(chef_run).to_not create_yum_repository('ius').with(
                    exclude: 'php73*'
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end

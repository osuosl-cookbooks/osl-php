require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'php_ini-test' }

CENTOS_7 = {
  platform: 'centos',
  version: '7.2.1511',
}.freeze

CENTOS_6 = {
  platform: 'centos',
  version: '6.8',
}.freeze

DEBIAN_8 = {
  platform: 'debian',
  version: '8.6',
}.freeze

ALL_PLATFORMS = [
  CENTOS_6,
  CENTOS_7,
  DEBIAN_8,
].freeze

RSpec.configure do |config|
  config.log_level = :fatal
end

require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'osl-php' }

CENTOS_7_OPTS = {
  platform: 'centos',
  version: '7.2.1511'
}.freeze

CENTOS_6_OPTS = {
  platform: 'centos',
  version: '6.7'
}.freeze

DEBIAN_8_OPTS = {
  platform: 'debian',
  version: '8.4'
}.freeze

RSpec.configure do |config|
  config.log_level = :fatal
end

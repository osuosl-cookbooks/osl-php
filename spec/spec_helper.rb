require 'chefspec'
require 'chefspec/berkshelf'

CENTOS_7_OPTS = {
  platform: 'centos',
  version: '7',
}.freeze

CENTOS_6_OPTS = {
  platform: 'centos',
  version: '6',
}.freeze

ALL_PLATFORMS = [
  CENTOS_6_OPTS,
  CENTOS_7_OPTS,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
end

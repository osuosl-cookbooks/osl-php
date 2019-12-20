require 'chefspec'
require 'chefspec/berkshelf'

CENTOS_8 = {
  platform: 'centos',
  version: '8',
}.freeze

CENTOS_7 = {
  platform: 'centos',
  version: '7',
}.freeze

CENTOS_6 = {
  platform: 'centos',
  version: '6',
}.freeze

ALL_PLATFORMS = [
  CENTOS_8,
  CENTOS_7,
  CENTOS_6,
].freeze

RSpec.configure do |config|
  config.log_level = :warn
end

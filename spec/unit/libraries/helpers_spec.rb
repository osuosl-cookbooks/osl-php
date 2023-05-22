require_relative '../../spec_helper'
require_relative '../../../libraries/helpers'

RSpec.describe OslPhp::Cookbook::Helpers do
  class DummyClass < Chef::Node
    include OslPhp::Cookbook::Helpers
  end

  subject { DummyClass.new }

  describe '#osl_php_available_ram' do
    it '1G ram' do
      allow(subject).to receive(:[]).with('memory').and_return({ 'total' => '1048576kB' })
      expect(subject.osl_php_available_ram).to eq 0
    end

    it '4G ram' do
      allow(subject).to receive(:[]).with('memory').and_return({ 'total' => '4194304kB' })
      expect(subject.osl_php_available_ram).to eq 2662
    end
  end

  describe '#osl_php_fpm_settings' do
    it '1G ram' do
      allow(subject).to receive(:[]).with('memory').and_return({ 'total' => '1048576kB' })
      expect(subject.osl_php_fpm_settings(52)).to eq({
        'max_children' => 4,
        'max_spare_servers' => 3,
        'min_spare_servers' => 1,
        'start_servers' => 1,
      })
    end

    it '4G ram' do
      allow(subject).to receive(:[]).with('memory').and_return({ 'total' => '4194304kB' })
      expect(subject.osl_php_fpm_settings(52)).to eq({
        'max_children' => 51,
        'max_spare_servers' => 38,
        'min_spare_servers' => 12,
        'start_servers' => 12,
      })
    end
  end
end

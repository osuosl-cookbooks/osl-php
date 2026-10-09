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

  describe '#osl_php_default_composer_version' do
    it 'returns latest Composer 2.X version from GitHub' do
      allow(subject).to receive(:osl_github_latest_version).with('composer/composer', '2').and_return('2.9.5')
      expect(subject.osl_php_default_composer_version).to eq('2.9.5')
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

  # Real run contexts: ChefSpec's step_into runs nested actions in the root context, so it cannot
  # tell a root-context service from a child-context one.
  describe '#osl_php_web_service_register' do
    let(:root) do
      Chef::RunContext.new(Chef::Node.new, Chef::CookbookCollection.new({}), Chef::EventDispatch::Dispatcher.new)
    end
    let(:child) { root.create_child }
    let(:caller_resource) { Chef::Resource::File.new('/tmp/caller', child) }

    it 'declares the service and the group in the root context and reloads the service from the group' do
      php_service = caller_resource.osl_php_web_service_register('php-fpm')
      group = root.resource_collection.find('notify_group[osl-php restart]')

      expect(php_service.run_context).to equal(root)
      expect(group.run_context).to equal(root)
      expect(child.resource_collection.all_resources).to be_empty
      expect(root.delayed_notifications(group).map { |n| [n.resource, n.action] }).to eq([[php_service, :reload]])
    end

    it 'reuses the root service on a second registration' do
      first = caller_resource.osl_php_web_service_register('php-fpm')
      second = caller_resource.osl_php_web_service_register('php-fpm')

      expect(second).to equal(first)
      expect(root.resource_collection.select { |r| r.to_s == 'service[php-fpm]' }.size).to eq(1)
    end
  end
end

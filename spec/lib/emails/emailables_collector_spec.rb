# frozen_string_literal: true
describe Emails::EmailablesCollector do
  include SpecTestHelper

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }
  let(:variables) { [user, project.decorate] }
  let(:instance_without_variables) do
    Class.new
  end
  let(:instance_with_variables) do
    instance = Class.new
    variables.each_with_index { |variable, index| instance.instance_variable_set "@v#{index}", variable }
    instance
  end

  describe '#perform' do
    def to_emailable(arr)
      Array.wrap(arr).map { |v| { model_id: v.id, model_type: v.class.name } }
    end

    it 'collects models of mixed types' do
      collected = described_class.new(instance_with_variables).perform
      expect(to_emailable collected).to match_array to_emailable([user, project])
    end

    it 'collects nothing' do
      collected = described_class.new(instance_without_variables).perform
      expect(collected).to be_empty
    end
  end
end

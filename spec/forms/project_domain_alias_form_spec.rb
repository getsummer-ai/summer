# frozen_string_literal: true
RSpec.describe ProjectDomainAliasForm do
  include SpecTestHelper

  let(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }

  context 'when the form is invalid' do
    it 'returns an error as the provided URL is empty' do
      model = described_class.new(project, { url: '' }).tap(&:update)
      expect( model.errors.full_messages).to include "Url is not a valid URL"
    end

    it 'returns an error as the provided URL does not contain a domain' do
      model = described_class.new(project, { url: 'https://' }).tap(&:update)
      expect( model.errors.full_messages).to include "Url can't be blank"
    end

    it 'returns an error as the provided URL does not contain a correct domain name' do
      model = described_class.new(project, { url: 'https://https://frank-task-218761.framer.app' }).tap(&:update)
      # an error comes from errors[:domain_alias]
      expect( model.errors.full_messages).to include "Url must be a valid url"
    end

    it 'returns an error as the domain is too long' do
      model = described_class.new(project, { url: "https://www.#{'local' * 100}.com" })

      expect( model.update).to be false
      # an error comes from project model - errors[:domain_alias]
      # there is a limit of 500 characters for the domain_alias
      expect( model.errors.full_messages).to include "Url is too long (maximum is 500 characters)"
    end

    it 'returns an error as the url is too long' do
      model = described_class.new(project, { url: "https://www.#{'local' * 2}.com/#{'local' * 2000}" })

      expect( model.update).to be false
      expect( model.errors.full_messages).to include "Url is too long (maximum is 1000 characters)"
    end

    it 'returns an error as the provided domain equals the primary domain name' do
      model = described_class.new(project, { url: "https://test.com/test" })
      expect( model.update).to be false
      expect( model.errors.full_messages).to \
        include "The staging domain must differ from </br><b>#{project.domain}</b>"
    end
  end

  context 'when the form is valid' do
    it 'takes a domain and put the value into the domain_alias column' do
      model = described_class.new(project, { url: "https://www.local.com/test" })

      expect( model.update).to be true
      expect( project.domain_alias).to eq 'www.local.com'
    end
  end
end

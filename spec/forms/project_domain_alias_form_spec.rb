# frozen_string_literal: true
RSpec.describe ProjectDomainAliasForm do
  include SpecTestHelper

  let(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }

  context 'when the form is invalid' do
    it 'returns an error as there is no domain alias' do
      model = described_class.new(project, { url: '' })

      expect( model.update).to be false
      expect( model.errors.full_messages).to include "Url is not a valid URL"
    end

    it 'returns an error as the domain is too long' do
      model = described_class.new(project, { url: "https://www.#{'local' * 100}.com" })

      expect( model.update).to be false
      expect( model.errors.full_messages).to include "Domain alias is too long (maximum is 500 characters)"
    end

    it 'returns an error as the url is too long' do
      model = described_class.new(project, { url: "https://www.#{'local' * 2}.com/#{'local' * 2000}" })

      expect( model.update).to be false
      expect( model.errors.full_messages).to include "Url is too long (maximum is 1000 characters)"
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

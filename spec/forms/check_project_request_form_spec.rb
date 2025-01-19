# frozen_string_literal: true
RSpec.describe CheckProjectRequestForm do
  include SpecTestHelper

  let(:user) { create_default_user }
  let!(:project) do
    user.projects.build(name: 'Test', protocol: 'http', domain: 'localhost.com', domain_alias: nil)
  end

  context 'when a form is valid' do
    it 'return true when origin and referer exist' do
      article_form =
        described_class.new(
          project,
          'http://localhost.com:3000',
          'http://localhost.com:3000/how-to',
        )
      expect(article_form.valid?).to be true
    end

    it 'returns true when an origin exists' do
      article_form = described_class.new(project, 'http://localhost.com:3000', nil)
      expect(article_form.valid?).to be true
    end

    it 'returns true when a referer exists' do
      article_form = described_class.new(project, nil, 'http://localhost.com:3000/how-to')
      expect(article_form.valid?).to be true
    end

    it 'returns true when the domain alias matches the origin value' do
      project.update!(domain_alias: 'test.com')
      article_form = described_class.new(project, 'http://test.com', nil)
      expect(article_form.valid?).to be true
    end
  end

  context 'when a form is invalid' do
    it 'returns false as origin and referrer are nils' do
      article_form = described_class.new(project, nil, nil)
      expect(article_form.valid?).to be false
      expect(article_form.errors.full_messages).to include('Referer is not a valid URL')
    end

    it 'returns false because the origin value does not match the domain of the project' do
      article_form = described_class.new(project, 'http://localhost:3000', nil)
      expect(article_form.valid?).to be false
      expect(article_form.errors.empty?).to be true
    end
  end
end

# frozen_string_literal: true
RSpec.describe ProjectArticleForm do
  include SpecTestHelper
  let(:user) { create_default_user }
  let!(:project) { user.projects.build(name: 'Test', protocol: 'http', domain: 'localhost.com') }

  context 'when url is correct' do
    it 'removes trailing slashes' do
      article_form = described_class.new(project, 'http://localhost.com/////')
      second_article_form = described_class.new(project, 'http://localhost.com//')
      expect(article_form.valid?).to be true
      expect(article_form.url).to eq 'http://localhost.com'
      expect(second_article_form.valid?).to be true
      expect(second_article_form.url).to eq 'http://localhost.com'
      expect(article_form.url_hash).to eq second_article_form.url_hash
    end

    it 'saves www and not www as separate links' do
      article_form = described_class.new(project, 'http://www.localhost.com/')
      second_article_form = described_class.new(project, 'http://localhost.com//')
      expect(article_form.valid?).to be true
      expect(article_form.url).to eq 'http://www.localhost.com'
      expect(second_article_form.valid?).to be true
      expect(second_article_form.url).to eq 'http://localhost.com'
      expect(article_form.url_hash).not_to eq second_article_form.url_hash
    end

    it 'removes the query and the anchor' do
      article_form = described_class.new(project, 'https://localhost.com/?q=1#adasd')
      expect(article_form.valid?).to be true
      expect(article_form.url).to eq 'https://localhost.com'
    end

    it 'removes the port if this is a basic port' do
      article_form = described_class.new(project, 'https://localhost.com:443/?q=1#adasd')
      expect(article_form.valid?).to be true
      expect(article_form.url).to eq 'https://localhost.com'
    end

    it 'saves the port if this is not a basic port' do
      article_form = described_class.new(project, 'https://localhost.com:3000/?q=1#adasd')
      expect(article_form.valid?).to be true
      expect(article_form.url).to eq 'https://localhost.com:3000'
    end

    it 'saves the link in downcase wayt' do
      article_form = described_class.new(project, 'https://LOCALHOST.com:3000/?q=1#adasd')
      expect(article_form.valid?).to be true
      expect(article_form.url).to eq 'https://localhost.com:3000'
    end
  end

  context 'when url is incorrect' do
    it 'does not pass the validation as url does not belong to the domain' do
      article_form = described_class.new(project, 'http://localhost/////')
      expect(article_form.valid?).to be false
      expect(article_form.errors.full_messages).to include 'The URL must belong to localhost.com'
      # expect(article_form.url).to eq 'http://localhost'
    end

    it 'does not pass the validation as there is no scheme' do
      article_form = described_class.new(project, 'localhost.com/////')
      expect(article_form.valid?).to be false
      expect(article_form.errors.full_messages).to eq ["Dirty url is not a valid URL"]
      # expect(article_form.url).to eq 'localhost.com'
    end

    it 'does not pass the validation as there is no correct scheme' do
      article_form = described_class.new(project, 'http:localhost.com/////')
      expect(article_form.valid?).to be false
      expect(article_form.errors.full_messages).to eq ["Dirty url is not a valid URL"]
      # expect(article_form.url).to eq 'http://localhost.com'
    end
  end
end

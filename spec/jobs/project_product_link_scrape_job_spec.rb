# frozen_string_literal: true

describe ProjectProductLinkScrapeJob do
  include SpecTestHelper

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }
  let!(:product) { project.products.create!(name: 'B', link: 'http://a.com/a', description: 'Hey') }

  describe '#perform with image path' do
    before do
      stub_request(:get, 'http://a.com/a').to_return(
        body: Rails.root.join('spec/fixtures/html/new-year-celebrations.html').read,
        headers: {
          'Content-Type' => 'text/html',
        },
      )
      stub_request(:get, 'http://a.com/og_images/default.png').to_return(
        body: Rails.root.join('spec/fixtures/files/og_image.jpg').read,
        headers: {
          'Content-Type' => 'image/jpeg',
        },
      )
    end

    it 'works well' do
      expect(product.icon).to be_nil
      described_class.perform(product.id)
      product.reload
      expect(product.icon).not_to be_nil
    end
  end

  describe '#perform with image url' do
    before do
      stub_request(:get, 'http://a.com/a').to_return(
        body: Rails.root.join('spec/fixtures/html/example-page-with-meta-tags.html').read,
        headers: {
          'Content-Type' => 'text/html',
        },
      )
      stub_request(
        :get,
        'https://images.unsplash.com/photo-1612528443702-f6741f70a049?q=80&w=880',
      ).to_return(
        body: Rails.root.join('spec/fixtures/files/og_image.jpg').read,
        headers: {
          'Content-Type' => 'image/jpeg',
        },
      )
    end

    it 'works well' do
      expect(product.icon).to be_nil
      described_class.perform(product.id)
      product.reload
      expect(product.icon).not_to be_nil
    end
  end
end

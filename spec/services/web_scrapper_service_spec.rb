# frozen_string_literal: true

describe WebScrapperService do
  it 'scrape and gets the title from the page' do
    stub_request(:get, 'http://localhost:3000/new-year-celebrations').to_return(
      body: Rails.root.join('spec/fixtures/html/new-year-celebrations.html').read,
      headers: {
        'Content-Type' => 'text/html',
      },
    )
    
    result = described_class.new('http://localhost:3000/new-year-celebrations').scrape

    expect(result.title).to eq 'New Year celebrations'
    expect(result.description).to be_nil
    expect(result.image_url).to eq '/og_images/default.png'
  end

  it 'scrapes and retrieve meta tags from the page' do
    stub_request(:get, 'https://example.com/page').to_return(
      body: Rails.root.join('spec/fixtures/html/example-page-with-meta-tags.html').read,
      headers: { 'Content-Type' => 'text/html' },
    )

    result = described_class.new('https://example.com/page').scrape
    expect(result.title).to eq 'Full range of 6 beers by Crafters Brewing'
    expect(result.description).to eq '150 words'
    expect(result.image_url).to eq 'https://images.unsplash.com/photo-1612528443702-f6741f70a049?q=80&w=880'
  end
end

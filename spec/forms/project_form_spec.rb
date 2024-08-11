# frozen_string_literal: true
RSpec.describe ProjectForm do
  include SpecTestHelper
  let(:user) { create_default_user }
  # before(:all) { user = create_default_user }

  context 'when the form is valid' do
    it 'passes the validation' do
      form = described_class.new(user, { name: 'Test Project', urls: ['http://localhost.com'] })
      expect(form.valid?).to be true
    end

    it 'creates a new project' do
      stub_const("ENV", ENV.to_hash.merge(
        'FREE_PLAN_CLICKS_THRESHOLD' => '30',
      ))
      form = described_class.new(user, { name: 'Test Project', urls: ['http://localhost.com'] })
      form.create
      expect(Project.count).to eq 1
      expect(Project.first.free_clicks_threshold).to eq 30
    end
  end

  context 'when the form is invalid' do
    it 'returns errors as there is no name' do
      form = described_class.new(user, { name: '', urls: ['http://localhost.com'] })
      expect(form.valid?).to be false
      expect(form.errors.full_messages).to include "Name can't be blank"
    end

    it 'returns errors as there is no urls' do
      form = described_class.new(user, { name: 'Test Project', urls: [] })
      expect(form.valid?).to be false
      expect(form.errors.full_messages).to include 'Urls is invalid'
    end

    it 'returns an error due to wrong Urls variable' do
      form = described_class.new(user, { name: 'Test Project', urls: '' })
      expect(form.valid?).to be false
      expect(form.errors.full_messages).to include 'Urls is not a valid URL'
    end

    it "returns an error as the urls variable isn't an array" do
      form = described_class.new(user, { name: 'Test Project', urls: 'https://123.com' })
      expect(form.valid?).to be false
      expect(form.errors.full_messages).to include 'Urls is invalid'
    end

    it 'returns an error as the urls contains domains with different hosts' do
      form =
        described_class.new(
          user,
          { name: 'Test Project', urls: %w[https://123.com https://345.com] },
        )
      expect(form.valid?).to be false
      expect(form.errors.full_messages).to include "Urls #{ProjectForm::MUST_MATCH_ERROR}"
    end

    it 'returns an error as there is a project with the same name already' do
      described_class.new(user, { name: 'Test Project', urls: ['http://localhost.com'] }).create
      form = described_class.new(user, { name: 'Test Project', urls: ['https://www.local.com'] })
      expect(form.create).to be_nil
      expect(form.errors.full_messages).to include 'Name is already taken'
    end

    it 'returns an error as there is a project with the same domain already' do
      described_class.new(user, { name: 'Test Project', urls: ['http://localhost.com'] }).create
      form = described_class.new(user, { name: 'Test Project 2', urls: ['https://localhost.com'] })
      expect(form.create).to be_nil
      expect(form.errors.full_messages).to include 'Domain is already taken'
    end

    it 'returns an error as this is the same domain but with www' do
      described_class.new(user, { name: 'Test Project', urls: ['http://localhost.com'] }).create
      form = described_class.new(user, { name: 'Test Project 2', urls: ['https://www.localhost.com'] })
      expect(form.create).to be_nil
      expect(form.errors.full_messages).to include 'Domain is already taken'
    end

    it 'returns an error as this is the same domain but without www' do
      described_class.new(user, { name: 'Test Project', urls: ['http://www.localhost.com'] }).create
      form = described_class.new(user, { name: 'Test Project 2', urls: ['https://localhost.com'] })
      expect(form.create).to be_nil
      expect(form.errors.full_messages).to include 'Domain is already taken'
    end

    it 'returns an error as this is the same domain but in uppercase' do
      described_class.new(user, { name: 'Test Project', urls: ['http://www.localhost.com'] }).create
      form = described_class.new(user, { name: 'Test Project 2', urls: ['https://www.LOCALHOST.com'] })
      expect(form.create).to be_nil
      expect(form.errors.full_messages).to include 'Domain is already taken'
    end

    it 'returns an error as this is the same domain but in downcase' do
      described_class.new(user, { name: 'Test Project', urls: ['http://www.LOCALHOST.com'] }).create
      expect(Project.first.domain).to eq 'www.localhost.com'
      form = described_class.new(user, { name: 'Test Project 2', urls: ['https://www.localhost.com'] })
      expect(form.create).to be_nil
      expect(form.errors.full_messages).to include 'Domain is already taken'
    end

    it 'returns an error as the domain does not have host' do
      form = described_class.new(user, { name: 'Test Project', urls: ['http:///'] })
      expect(form.create).to be_nil
      expect(form.errors.full_messages).to match ["Domain must be a valid url", "Domain can't be blank"]
    end
  end
end

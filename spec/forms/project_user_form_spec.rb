# frozen_string_literal: true

RSpec.describe ProjectUserForm do
  include SpecTestHelper

  let(:user) { create_default_user(email: 'test@example.com') }
  let(:project) do
    user.projects.create!(name: 'Test', protocol: 'https', domain: 'example.com', paths: [''])
  end
  let(:project_user) { project.project_users.take }

  describe '#initialize' do
    it 'sets email and role from attributes if provided' do
      form = described_class.new(project_user, email: 'test@example.com', role: 'viewer')
      expect(form.email).to eq('test@example.com')
      expect(form.role).to eq('viewer')
    end

    it 'defaults email to project_user user email if not provided' do
      form = described_class.new(project_user)
      expect(form.email).to eq('test@example.com')
    end

    it 'defaults role to project_user role if not provided' do
      form = described_class.new(project_user)
      expect(form.role).to eq('admin')
    end
  end

  describe '#save' do
    context 'when valid' do
      it 'updates project_user attaching existing user and returns true' do
        form = described_class.new(project_user, email: 'test@example.com', role: 'admin')
        expect(form.save).to be true
        expect(project_user.invited_email_address).to eq 'test@example.com'
        expect(project_user.role).to eq 'admin'
        expect(project_user.user).to eq user
      end

      it 'updates project_user without attaching a user and returns true' do
        project_user.user = nil
        form = described_class.new(project_user, email: 'test2@example.com', role: 'admin')
        expect(form.save).to be true
        expect(project_user.invited_email_address).to eq 'test2@example.com'
        expect(project_user.role).to eq 'admin'
        expect(project_user.user).to be_nil
      end
    end

    context 'when invalid' do
      it 'returns false if validation fails' do
        form = described_class.new(project_user, email: '', role: '')
        expect(form.save).to be false
      end

      it 'adds project_user errors to form errors and returns false' do
        form = described_class.new(project_user, email: 'example.com', role: 'admin')
        expect(form.save).to be false
        expect(form.errors.full_messages).to include('Email is invalid')
      end
    end
  end
end

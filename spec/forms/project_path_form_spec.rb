# frozen_string_literal: true

RSpec.describe ProjectPathForm do
  include SpecTestHelper
  let(:user) { create_default_user }
  let!(:project) { user.projects.build(name: 'Test', protocol: 'https', domain: 'example.com', paths: ['']) }
  let(:project_path) { Project::ProjectPath.new(project) }

  describe 'common validations' do
    it 'validates presence of value' do
      form = ProjectPathForm.new(project_path, value: '')
      expect(form).to be_invalid
      expect(form.errors[:value]).to include("can't be blank")
    end

    it 'validates URL format' do
      form = ProjectPathForm.new(project_path, value: 'not-a-url')
      expect(form).to be_invalid
      expect(form.errors[:value]).to include('is not a valid URL')
    end

    it 'validates domain correctness' do
      form = ProjectPathForm.new(project_path, value: 'https://wrong-domain.com/path')
      expect(form).to be_invalid
      expect(form.errors[:base]).to include("The URL must belong to example.com")
    end

    it 'validates default path uniqueness' do
      form = ProjectPathForm.new(project_path, value: 'https://example.com')
      expect(form).to be_invalid
      expect(form.errors[:base]).to include('URL already exists')
    end

    it 'validates custom path uniqueness' do
      project.paths << '/existing-path'
      form = ProjectPathForm.new(project_path, value: 'https://example.com/existing-path')
      expect(form).to be_invalid
      expect(form.errors[:base]).to include('URL already exists')
    end

    it 'passes all validation rules' do
      form = ProjectPathForm.new(project_path, value: 'https://example.com/')
      expect(form).to be_valid
    end
  end

  describe '#create' do
    it 'limits maximum amount of paths' do
      5.times { |i| project.paths << "/path-#{i}" }
      form = ProjectPathForm.new(project_path, value: 'https://example.com/new-path')
      expect(form.create).to be_nil
      expect(form.errors[:base]).to include('Max URL amount is 5')
    end

    it 'adds a new path to the project' do
      form = ProjectPathForm.new(project_path, value: 'https://example.com/new-path')
      expect { form.create }.to change { project.paths.count }.by(1)
    end

    it 'returns nil if value is empty' do
      form = ProjectPathForm.new(project_path, value: '')
      expect(form.create).to be_nil
      expect(form.errors[:value]).to include("can't be blank")
    end
  end

  describe '#update' do
    it 'updates an existing path' do
      project.paths << '/old-path'
      persisted_path = Project::ProjectPath.new(project, '/old-path')
      form = ProjectPathForm.new(persisted_path, value: 'https://example.com/new-path')
      expect { form.update }.to change { project.paths.last }.from('/old-path').to('/new-path')
    end

    it 'updates path if path has not changed' do
      form = ProjectPathForm.new(project.smart_paths.first, value: 'https://example.com')
      expect { form.update }.not_to change { project.paths.last }.from('')
    end

    it 'returns errors if path and value are invalid' do
      form = ProjectPathForm.new(project_path, value: '')
      expect(form.update).to be_nil
      expect(form.errors[:value]).to include("can't be blank")
      expect(form.errors[:path]).to include("is invalid")
    end

    it 'returns nil if path is invalid' do
      form = ProjectPathForm.new(project.smart_paths.first, value: '')
      expect(form.update).to be_nil
      expect(form.errors.messages).to eq(value: ["can't be blank"])
    end
  end

  describe '#destroy' do
    it 'removes a path from the project' do
      project.paths << '/to-be-deleted'
      persisted_path = Project::ProjectPath.new(project, '/to-be-deleted')
      form = ProjectPathForm.new(persisted_path)
      expect { form.destroy }.to change { project.paths.count }.by(-1)
    end

    it 'does not destroy the last path from the project' do
      persisted_path = Project::ProjectPath.new(project, '')
      form = ProjectPathForm.new(persisted_path)
      expect(form.destroy).to be_nil
      expect(form.errors.messages).to eq(base: ["You cannot delete the last URL"])
    end

    it 'returns nil if invalid' do
      form = ProjectPathForm.new(project_path)
      expect(form.destroy).to be_nil
      expect(form.errors.messages).to eq(value: ["can't be blank"], path: ["is invalid"])
    end

    it 'returns nil if path is not persisted' do
      not_persisted_path = Project::ProjectPath.new(project, 'not-persisted')
      form = ProjectPathForm.new(not_persisted_path)
      expect(form.destroy).to be_nil
      expect(form.errors[:path]).to include('is invalid')
    end
  end
end

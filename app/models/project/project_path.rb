# frozen_string_literal: true
class Project
  class ProjectPath
    attr_reader :project, :path

    # @param [Project] project
    # @param [String, nil] path
    def initialize(project, path = nil)
      @project = project
      @path = path
    end

    def self.calculate_id(path)
      return path if path == 'default'
      path.to_s == '' ? 'default' : Base64.encode64(path.to_s).strip
    end

    def id
      @id ||= self.class.calculate_id(@path)
    end

    def url
      @url ||= "#{@project.protocol}://#{@project.domain}#{@path}"
    end

    def to_s
      @path || ''
    end

    def to_param
      id
    end

    # @return [ActiveRecord::Relation<ProjectPage>]
    def project_page_ids_query
      @project.pages.select('id').where('url LIKE ?', "#{url}%")
    end

    def persisted?
      existed_path = @project.paths.include?(path)
      existed_path.present?
    end

    def last_one?
      persisted? && @project.paths.size == 1
    end
  end
end

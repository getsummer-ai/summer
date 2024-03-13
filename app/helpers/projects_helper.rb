# frozen_string_literal: true

module ProjectsHelper
  def project_list
    return [] unless user_signed_in?
    @project_list ||= current_user.projects.available.select(:id, :name).order(:id).all
  end
end

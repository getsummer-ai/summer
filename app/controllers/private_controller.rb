# frozen_string_literal: true

class PrivateController < ApplicationController
  layout 'private'

  def find_project
    @project = current_user.projects.find(BasicEncrypting.decode(params[:project_id].to_s))
    # @type [Project]
    @current_project = @project
    return @project if current_user.default_project_id == @project.id
    current_user.update_attribute(:default_project_id, @project.id)
    @project
  end
end

# frozen_string_literal: true
# @!attribute current_project
#  @return [Project]
class PrivateController < ApplicationController
  layout 'private'
  attr_reader :current_project

  def private_or_turbo_layout
    return 'turbo_rails/frame' if turbo_frame_request?
    'private'
  end

  def find_project
    # @type [Project]
    @project = current_user.projects.available.find(BasicEncrypting.decode(params[:project_id].to_s))
    # @type [Project]
    @current_project = @project
    return @project if current_user.default_project_id == @project.id
    current_user.update_attribute(:default_project_id, @project.id)
    @project
  end


  # @param [String] path
  def generate_modal_anchor(path)
    modal_anchor_to_open = Base64.encode64(path)
    "m=#{modal_anchor_to_open}"
  end
end

# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  layout :custom_layout

  def custom_layout
    return 'turbo_rails/frame' if turbo_frame_request?
    'main'
  end

  def homepage
    render 'homepage'
  end

  def about
    @project_id = current_user&.projects&.pick(:id)
  end

end

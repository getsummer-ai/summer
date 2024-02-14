# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  helper_method :example_project_id

  layout :custom_layout

  def custom_layout
    return 'turbo_rails/frame' if turbo_frame_request?
    'main'
  end

  def homepage
    render 'homepage'
  end

  def about
  end

  def new_year_celebration
  end

  def how_to_make_contracts_more_human
  end

  def example_project_id
    @example_project_id ||= current_user&.default_project&.uuid
  end
end

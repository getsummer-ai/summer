# frozen_string_literal: true
class ModalsController < ApplicationController
  include DeviseMethodsHelper

  skip_before_action :authenticate_user!
  # before_action :ensure_frame_response

  layout 'turbo_rails/frame'

  def login
    redirect_to new_session_path(:user) unless turbo_frame_request?
  end

  def sign_up
    redirect_to new_registration_path(:user) unless turbo_frame_request?
  end

  def restore_password
    redirect_to new_password_path(:user) unless turbo_frame_request?
  end

  private

  def ensure_frame_response
    return unless Rails.env.development?
    redirect_to root_path unless turbo_frame_request?
  end
end

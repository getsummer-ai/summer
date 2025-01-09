# frozen_string_literal: true
# @!attribute current_project
#  @return [Project]
class AdminController < ApplicationController
  include Pagy::Backend
  before_action :require_admin!

  layout 'admin'

  protected

    def require_admin!
      raise ActionController::RoutingError, 'Not Found' unless true_user.is_admin?
    end
end

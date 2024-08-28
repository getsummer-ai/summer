# frozen_string_literal: true
module Admin
  class UsersController < ApplicationController
    include Pagy::Backend
    before_action :require_admin!

    layout 'admin'

    def index
      @search_field = params[:search].present? ? params[:search].strip : ''
      query = User.joins(:default_project).order(:id)
      if params[:search].present?
        query = query.where('email ILIKE ?', "%#{params[:search]}%").or(
          query.where('domain ILIKE ?', "%#{params[:search]}%")
        )
      end
      @pagy, @users = pagy(query, items: 10, link_extra: 'data-turbo-frame="users"')
    end

    def impersonate
      user = User.find(params[:id])
      impersonate_user(user)
      redirect_to root_path
    end

    def stop_impersonating
      stop_impersonating_user
      redirect_to root_path
    end

    private

    def require_admin!
      raise ActionController::RoutingError, 'Not Found' unless true_user.is_admin?
    end
  end
end

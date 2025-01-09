# frozen_string_literal: true
module Admin
  class UsersController < AdminController
    def index
      @search_field = params[:search].present? ? params[:search].strip : ''
      query = User.joins(:default_project).order(:id)
      if params[:search].present?
        query =
          query.where('email ILIKE ?', "%#{params[:search]}%").or(
            query.where('domain ILIKE ?', "%#{params[:search]}%"),
          )
      end
      @pagy, @users =
        pagy(query.includes(:default_project), items: 10, link_extra: 'data-turbo-frame="users"')
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
  end
end

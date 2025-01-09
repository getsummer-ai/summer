# frozen_string_literal: true
module Admin
  class EmailsController < AdminController
    before_action :find_email, only: %i[show preview]

    layout false, only: [:preview]

    def index
      @search_field = params[:search].present? ? params[:search].strip : ''
      query = Email.order(created_at: :desc)
      if params[:search].present?
        query =
          Email.where('"to" ILIKE ?', "%#{params[:search]}%").or(
            Email.where('subject ILIKE ?', "%#{params[:search]}%"),
          )
      end
      @pagy, @emails = pagy(query, items: 10, link_extra: 'data-turbo-frame="emails"')
    end

    def show
    end

    def preview
    end

    def find_email
      @email = Email.find(params[:id])
    end
  end
end

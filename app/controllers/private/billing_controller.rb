# frozen_string_literal: true
module Private
  class BillingController < PrivateController
    include Pagy::Backend

    layout :private_or_turbo_layout

    def index
      @projects = current_user.projects.available.order(:id).all
    end
  end
end

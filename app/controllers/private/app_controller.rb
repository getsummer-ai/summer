# frozen_string_literal: true
module Private
  class AppController < PrivateController
    include ActiveStorage::SetCurrent

    def index
      # render formats: :html
    end
  end
end

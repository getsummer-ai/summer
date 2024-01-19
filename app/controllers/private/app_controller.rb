# frozen_string_literal: true
class Private::AppController < PrivateController
  include ActiveStorage::SetCurrent

  def index
    # render formats: :html
  end
end

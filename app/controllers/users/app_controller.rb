# frozen_string_literal: true
class Users::AppController < PrivateController
  include ActiveStorage::SetCurrent

  def index
    # render formats: :html
  end
end

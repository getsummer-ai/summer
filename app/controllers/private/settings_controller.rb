# frozen_string_literal: true
module Private
  class SettingsController < PrivateController
    before_action :find_project

    layout :custom_layout

    def custom_layout
      return 'turbo_rails/frame' if turbo_frame_request?
      'private'
    end

    def index
      @statistics = ProjectPath::InfoViewModelsGenerator.new(@current_project)

    end
  end
end

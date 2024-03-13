# frozen_string_literal: true
module Private
  class SettingsController < PrivateController
    before_action :find_project

    def index
      @statistics = ProjectPath::InfoViewModelsGenerator.new(@current_project)
    end
  end
end

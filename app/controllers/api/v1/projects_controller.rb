# frozen_string_literal: true
module Api
  module V1
    class ProjectsController < ApplicationController
      def show
        render json: { project: current_project }
      end
    end
  end
end

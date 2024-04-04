# frozen_string_literal: true
module Api
  module V1
    module Pages
      #
      # Controller with common logic for user API
      #
      class DefaultController < Api::V1::ApplicationController
        before_action :extract_data_from_id_param

        def extract_data_from_id_param
          decoded_info = BasicEncrypting.decode_array(params[:page_id], 2)
          return head(:bad_request) if decoded_info.nil? || decoded_info.length != 2

          expired_at = decoded_info[1]
          return head(:gone) if Time.now.utc.to_i > expired_at
          @page_id = decoded_info[0]
        end

        # @return [ProjectPage]
        def project_page
          @project_page ||= current_project.pages.find(@page_id)
        end
      end
    end
  end
end

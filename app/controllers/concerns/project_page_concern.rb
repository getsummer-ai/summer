# frozen_string_literal: true
module ProjectPageConcern
  extend ActiveSupport::Concern

  included do
    before_action :extract_data_from_id_param
  end

  def extract_data_from_id_param
    decoded_info = BasicEncrypting.decode_array(params[:id], 2)
    return head(:bad_request) if decoded_info.nil?

    expired_at = decoded_info[1]
    return head(:gone) if Time.now.utc.to_i > expired_at
    @page_id = decoded_info[0]
  end

  # @return [ProjectPage]
  def project_page
    @project_page ||= current_project.pages.find(@page_id)
  end
end

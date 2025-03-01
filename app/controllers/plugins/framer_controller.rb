# frozen_string_literal: true
module Plugins
  class FramerController < PluginController
    include LocaleConcern

    before_action :check_query_params, only: :login
    before_action :check_api_key, only: :login
    before_action :clear_all_sessions

    def login
      session[:framer_session_id] = api_key.id
      redirect_to new_user_session_path(framer_session_id: api_key.id)
    end

    private
      
    def check_api_key
      return unless api_key.key_type != 'framer'

      render json: { message: 'Invalid Api-Key' }, status: :forbidden
    end

    def check_query_params
      return if UUID.validate(params[:session_id]) && parsed_info.present?
      render json: { message: 'Invalid params' }, status: :bad_request
    end

    def parsed_info
      return nil if params[:info].blank?
      JSON.parse(Base64.decode64(params[:info].to_s))
    rescue JSON::ParserError
      nil
    end
    
    # @return [ProjectApiKey]
    def api_key
      @api_key ||= ProjectApiKey.find_or_create_by!(id: params[:session_id]) do |user|
        user.key_type = 'framer'
        user.details = parsed_info.slice('project_id', 'production', 'staging')
      end
    end

    def clear_all_sessions
      sign_out(current_user)
      session[:framer_session_id] = nil
    end
  end
end

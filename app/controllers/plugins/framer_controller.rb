# frozen_string_literal: true
module Plugins
  class FramerController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[login]

    before_action :check_session_id
    before_action :check_framer_data_params, only: :login
    before_action :clear_all_sessions, only: :login

    after_action :clear_framer_info_from_session, only: :success

    def login
      api_key =
        ProjectApiKey.find_or_create_by!(id: params[:session_id]) do |user|
          user.key_type = 'framer'
          user.details = parsed_info.slice('project_id', 'production', 'staging')
        end

      if api_key.key_type != 'framer'
        return render json: { message: 'Invalid Api-Key' }, status: :forbidden
      end

      session[:framer_session_id] = api_key.id
      redirect_to new_user_session_path(framer_session_id: api_key.id)
    end

    def success
      if session[:framer_session_id].present? && session[:framer_session_id] == params[:session_id]
        api_key = ProjectApiKey.find(params[:session_id])
        if api_key.present?
          api_key.update!(
            activated_at: Time.now.utc,
            owner_id: current_user.id,
            expired_at: 6.months.from_now,
          )
        end
        return render json: { message: 'Success' }
      end
      render json: { message: 'Error' }
    end

    private

    def check_session_id
      return if UUID.validate(params[:session_id])
      render json: { message: 'Invalid params' }, status: :bad_request
    end

    def check_framer_data_params
      return if parsed_info.present?
      render json: { message: 'Invalid params' }, status: :bad_request
    end

    def parsed_info
      @parsed_info ||= params[:info].present? ? JSON.parse(Base64.decode64(params[:info].to_s)) : nil
    rescue JSON::ParserError
      nil
    end

    def clear_all_sessions
      sign_out(current_user)
      clear_framer_info_from_session
    end

    def clear_framer_info_from_session
      session[:framer_session_id] = nil
    end
  end
end

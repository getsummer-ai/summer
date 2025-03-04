# frozen_string_literal: true
module Plugins
  class FramerController < ApplicationController
    layout 'framer_login'

    before_action do
      next if UUID.validate(params[:session_id])
      render 'plugins/framer/bad_request', status: :bad_request
    end

    with_options only: :login do
      skip_before_action :authenticate_user!
      before_action :check_framer_data_params
      before_action { find_project_api_key(or_create: true) }
      before_action { check_project_api_key_exists_and_it_belongs_to_framer }
      before_action :clear_all_sessions
    end

    with_options only: [:success, :create_project, :select_project] do
      before_action :find_project_api_key
      before_action { check_project_api_key_exists_and_it_belongs_to_framer }
      before_action :check_framer_session_id_equals_server_session_info
      before_action :check_project_api_key_is_not_expired
    end

    def login
      session[:framer_session_id] = @api_key.id
      if current_user.present?
        if current_user.id == @api_key.owner_id
          return redirect_to success_plugins_framer_path(session_id: @api_key.id)
        end
        sign_out(current_user)
      end

      redirect_to new_user_session_path(framer_session_id: @api_key.id)
    end

    def success
      return if @api_key.expired_at?
      @api_key.update!(activated_at: Time.now.utc, owner_id: current_user.id, expired_at: 6.months.from_now)
    end

    def create_project
      @project = Project::CreateNewService.new(
        current_user,
        name: @api_key.details['name'],
        domain: @api_key.details['domain'],
        domain_alis: @api_key.details['domain_alis'],
      )
      model = @project.create
      if model.errors.any?
        flash[:notice] = model.errors.full_messages.join(', ')
      else
        @api_key.update! project_id: model.id
        flash[:notice] = 'Project was successfully created.'
      end

      redirect_to success_plugins_framer_path(session_id: @api_key.id)
    end

    def select_project
      project = Project.available.find_by!(uuid: params[:project_id], user_id: current_user.id)
      if @api_key.project_id.nil?
        @api_key.update!(project_id: project.id)
        flash[:notice] = "Project #{project.name} has been selected."
      end

      redirect_to success_plugins_framer_path(session_id: @api_key.id)
    end

    private

    # @return [ProjectApiKey, nil]
    def find_project_api_key(or_create: false)
      return @api_key if defined?(@api_key)

      @api_key = ProjectApiKey.find_by(id: params[:session_id])

      if @api_key.nil? && or_create
        @api_key = ProjectApiKey.create!(
          id: params[:session_id],
          key_type: 'framer',
          details: parsed_info.slice('project_id', 'production', 'staging')
        )
      end
      @api_key
    end
    
    def check_framer_data_params
      return if parsed_info.present?
      render 'plugins/framer/bad_request', status: :bad_request 
    end

    def check_project_api_key_is_not_expired
      if @api_key.expired_at? && @api_key.expired_at < Time.now.utc
        render 'plugins/framer/session_expired', status: :gone
      end
    end

    def check_framer_session_id_equals_server_session_info
      return if session[:framer_session_id] == params[:session_id]
      render 'plugins/framer/not_found', status: :not_found
    end

    def check_project_api_key_exists_and_it_belongs_to_framer
      return if @api_key.present? && @api_key.key_type == 'framer'
      render 'plugins/framer/not_found', status: :not_found
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

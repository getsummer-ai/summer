# frozen_string_literal: true
module FramerAuthSessionConcern

  # @return [String, nil]
  def framer_auth_session_id
    session[:framer_session_id]
  end

  def clear_framer_auth_session_if_no_param
    if params[:framer_session_id].nil? && session[:framer_session_id].present?
      session[:framer_session_id] = nil
    end
  end
end

# frozen_string_literal: true
module FramerAuthSessionConcern
  def default_url_options
    super.merge(
      framer_session_id:
        framer_auth_session_id_query_param.presence || framer_auth_session_id_session_value
    )
  end

  private
  # @return [String, nil]
  def framer_auth_session_id_session_value
    session[:framer_session_id]
  end

  # @return [String, nil]
  def framer_auth_session_id_query_param
    params[:framer_session_id]
  end

  def clear_framer_auth_session_if_no_framer_auth_request
    if framer_auth_session_id_query_param.nil? && framer_auth_session_id_session_value.present?
      session[:framer_session_id] = nil
    end
  end

  def simplify_form_csrf_token_for_framer_auth_request
    # The problem is with ActionController::RequestForgeryProtection:
    # Since its masked_authenticity_token clears the query params when creating an authenticity_token for a form
    # and
    # valid_per_form_csrf_token? it doesn't clear query params before comparing session token with incoming token
    # we need to simplify CSRF token as we want to keep framer_session_id in the query params
    self.per_form_csrf_tokens = false if framer_auth_session_id_query_param.present?
  end
end

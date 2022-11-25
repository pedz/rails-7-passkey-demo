class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    session[:user_id] = nil
  end

  def current_user
    @current_user ||= (User.find_by(id: session[:user_id]) if session[:user_id])
  end

  def external_id(webauthn_credential)
    Base64.strict_encode64(webauthn_credential.raw_id)
  end
end

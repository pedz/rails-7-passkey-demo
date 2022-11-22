# frozen_string_literal: true

# All actions by this controller and it's subclasses require the user
# to be logged in.  This will be the parent class for most of the
# other controllers with the exceptions being the ones that create the
# session and authenticate the user.
class AuthenticatedController < ApplicationController
  before_action :enforce_current_user

  private

  def enforce_current_user
    if current_user.blank?
      session[:original_uri] = request.env["REQUEST_URI"]
      redirect_to new_session_path 
    end
  end
end

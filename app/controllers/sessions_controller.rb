# Creates and manages the session when a registered user logs in.
class SessionsController < ApplicationController
  # GET    /session/new(.:format)
  def new; end

  # POST   /session(.:format)
  def create
    user = User.find_by(username: username_param)

    if user
      get_options = WebAuthn::Credential.options_for_get(
        allow: user.credentials.pluck(:external_id),
        user_verification: 'required'
      )

      save_authentication('challenge' => get_options.challenge, 'username' => session_params[:username])

      hash = {
        original_url: session['original_uri'],
        callback_url: callback_session_path(format: :json),
        get_options: get_options
      }

      respond_to do |format|
        logger.debug { "respond with: #{hash}" }
        format.json { render json: hash }
      end
    else
      respond_to do |format|
        logger.debug { "Username #{username_param} does not exist" }
        format.json { render json: { errors: ['Username does not exist'] }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /session(.:format)
  def destroy
    sign_out

    redirect_to root_path
  end

  # POST   /session/callback(.:format)
  def callback
    logger.debug { 'in session#callback' }
    webauthn_credential = WebAuthn::Credential.from_get(params)

    user = User.find_by(username: saved_username)

    raise "user #{saved_username} never initiated sign up" unless user

    credential = user.credentials.find_by(external_id: external_id(webauthn_credential))

    begin
      webauthn_credential.verify(
        saved_challenge,
        public_key: credential.public_key,
        sign_count: credential.sign_count,
        user_verification: true
      )

      credential.update!(sign_count: webauthn_credential.sign_count)
      sign_in(user)

      render json: { status: 'ok' }, status: :ok
    rescue WebAuthn::Error => e
      render json: "Verification failed: #{e.message}", status: :unprocessable_entity
    ensure
      session.delete(:current_authentication)
    end
  end

  private

  def username_param
    session_params[:username]
  end

  def session_params
    params.require(:session).permit(:username)
  end

  def saved_authentication
    session['current_authentication']
  end

  def save_authentication(v)
    session['current_authentication'] = v
  end

  def saved_username
    saved_authentication['username']
  end

  def saved_challenge
    saved_authentication['challenge']
  end
end

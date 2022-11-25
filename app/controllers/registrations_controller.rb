# This controls the registration of a new user
class RegistrationsController < ApplicationController
  # GET    /registration/new(.:format)
  def new; end

  # POST   /registration(.:format)
  def create
    # A new User is not saved until the callback.  Its webauthn_id is
    # generated in the model.  session is used to preserve the values
    # across requests.
    user = User.find_by(user_args) || User.new(user_args)

    create_options = WebAuthn::Credential.options_for_create(
      user: {
        name: params[:registration][:username],
        id: user.webauthn_id
      },
      authenticator_selection: { user_verification: 'required' },
      exclude: user.credentials.pluck(:external_id)
    )

    if user.valid?
      session[:current_registration] = { challenge: create_options.challenge, user_attributes: user.attributes }

      hash = {
        callback_url: callback_registration_path(format: :json),
        create_options: create_options
      }
  
    respond_to do |format|
        format.json { render json: hash }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # POST   /registration/callback(.:format)
  def callback
    webauthn_credential = WebAuthn::Credential.from_create(params)

    logger.debug { "session['current_registration']['user_attributes'] = #{session['current_registration']['user_attributes']}" }

    unless (user = User.find_by(username: session_username))
      user = User.create!(session_user_attribuets)
    end

    begin
      webauthn_credential.verify(session['current_registration']['challenge'], user_verification: true)
      logger.debug { 'verify worked' }

      credential = user.credentials.build(
        external_id: external_id(webauthn_credential),
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count
      )

      if credential.save
        logger.debug { 'save worked' }
        sign_in(user)

        render json: { status: 'ok' }, status: :ok
      else
        logger.debug { 'save failed' }
        render json: "Couldn't register your Security Key", status: :unprocessable_entity
      end
    rescue WebAuthn::Error => e
      logger.debug { "verify raised error: #{e}" }
      render json: "Verification failed: #{e.message}", status: :unprocessable_entity
    ensure
      logger.debug { 'delete session' }
      session.delete('current_registration')
    end
  end

  private

  def user_args
    { username: params[:registration][:username] }
  end

  def session_user_attribuets
    session['current_registration']['user_attributes']
  end

  def session_username
    session_user_attribuets['username']
  end
end

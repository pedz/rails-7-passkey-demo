# This controls the registration of a new user
class RegistrationsController < ApplicationController
  # GET    /registration/new(.:format)
  def new; end

  # POST   /registration(.:format)
  def create
    # A new User is not saved until the callback.  Its webauthn_id is
    # generated in the model.  session is used to preserve the values
    # across requests.
    user = User.new(username: username_param)

    create_options = WebAuthn::Credential.options_for_create(
      user: {
        name: username_param,
        id: user.webauthn_id
      },
      authenticator_selection: { user_verification: 'required' },
    )

    if user.valid?
      save_registration('challenge' => create_options.challenge, 'user_attributes' => user.attributes)

      hash = {
        original_url: session['original_uri'],
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

    user = User.create!(saved_user_attribuets)
    logger.debug { 'create worked' }

    begin
      webauthn_credential.verify(saved_challenge, user_verification: true)
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
        render json: 'Could not register your Security Key', status: :unprocessable_entity
      end
    rescue WebAuthn::Error => e
      logger.debug { "verify raised error: #{e}" }
      render json: "Verification failed: #{e.message}", status: :unprocessable_entity
    rescue Exception => e
      logger.debug { "Unexpected exception: #{e}" }
      render json: "Verification failed: #{e.message}", status: :unprocessable_entity
    ensure
      logger.debug { 'delete session' }
      session.delete(:current_registration)
    end
  end

  private

  def username_param
    registration_params[:username]
  end
  
  def registration_params
    params.require(:registration).permit(:username)
  end

  def saved_registration
    session['current_registration']
  end

  def save_registration(v)
    session['current_registration'] = v
  end
  
  def saved_user_attribuets
    saved_registration['user_attributes']
  end

  def saved_username
    saved_user_attribuets['username']
  end

  def saved_challenge
    saved_registration['challenge']
  end
end

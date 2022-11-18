# == Schema Information
#
# Table name: users
#
#  id          :bigint           not null, primary key
#  username    :string
#  webauthn_id :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class User < ApplicationRecord
  CREDENTIAL_MIN_AMOUNT = 1

  has_many :credentials, dependent: :delete_all

  validates :username, presence: true, uniqueness: true

  after_initialize do
    self.webauthn_id ||= WebAuthn.generate_user_id
  end

  def can_delete_credentials?
    credentials.size > CREDENTIAL_MIN_AMOUNT
  end
end

# == Schema Information
#
# Table name: credentials
#
#  id          :bigint           not null, primary key
#  user_id     :bigint           not null
#  external_id :string
#  public_key  :string
#  sign_count  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class CredentialTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

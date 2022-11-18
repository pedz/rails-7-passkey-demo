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
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

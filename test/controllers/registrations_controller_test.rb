require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get registrations_new_url
    assert_response :success
  end

  test "should get create" do
    get registrations_create_url
    assert_response :success
  end

  test "should get destroy" do
    get registrations_destroy_url
    assert_response :success
  end

  test "should get callback" do
    get registrations_callback_url
    assert_response :success
  end
end

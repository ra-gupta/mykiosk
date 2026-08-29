require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "signing up and back in with a mobile number and OTP" do
    assert_enqueued_with(job: SmsJob) do
      post phone_verification_path, params: { phone_number: "98765 43210" }
    end
    user = User.sole
    assert_equal "9876543210", user.phone_number
    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "h1", "Enter the code"

    post session_path, params: { phone_number: user.phone_number, code: User.start_phone_verification("9876543210").otp }
    assert_redirected_to root_path
    assert_nil user.reload.otp_digest

    get orders_path
    assert_response :success
  end

  test "a stale or wrong OTP is refused" do
    user = User.start_phone_verification("9876543210")

    post session_path, params: { phone_number: user.phone_number, code: "000000" }
    assert_redirected_to new_session_path

    travel User::OTP_VALIDITY + 1.minute
    post session_path, params: { phone_number: user.phone_number, code: user.otp }
    assert_redirected_to new_session_path
  end

  test "email and password still work alongside phone sign in" do
    User.create!(email_address: "shopper@example.com", password: "secret123")

    post session_path, params: { email_address: "shopper@example.com", password: "wrong" }
    assert_redirected_to new_session_path

    post session_path, params: { email_address: "shopper@example.com", password: "secret123" }
    assert_redirected_to root_path
  end

  test "api: OTP sign in and device token registration" do
    post api_v1_phone_verification_path, params: { phone_number: "9876543210" }
    assert_response :created

    post api_v1_session_path, params: { phone_number: "9876543210", code: User.start_phone_verification("9876543210").otp }
    assert_response :created

    post api_v1_device_tokens_path, params: { token: "fcm-abc" },
      headers: { "Authorization" => "Bearer #{response.parsed_body["token"]}" }
    assert_response :created
    assert_equal "9876543210", DeviceToken.sole.user.phone_number
  end
end

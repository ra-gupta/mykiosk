require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "a phone verification is not re-sent within a minute" do
    user = nil
    assert_enqueued_jobs 1, only: SmsJob do
      user = User.start_phone_verification("98765 43210")
    end
    first_code = user.otp

    assert_no_enqueued_jobs only: SmsJob do
      User.start_phone_verification("9876543210")
    end
    assert user.reload.authenticate_otp(first_code), "the first code still works"

    user.update!(otp_sent_at: 2.minutes.ago)
    assert_enqueued_jobs 1, only: SmsJob do
      User.start_phone_verification("9876543210")
    end
    assert_not user.reload.authenticate_otp(first_code), "a fresh code replaces the old one"
  end

  test "the OTP text carries the shop's name" do
    user = User.start_phone_verification("9876543210")
    assert_enqueued_with(job: SmsJob, args: [ "9876543210", "#{user.otp} is your #{Shop.name} code. It expires in 5 minutes." ])
  end
end

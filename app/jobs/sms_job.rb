class SmsJob < ApplicationJob
  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :polynomially_longer

  def perform(phone_number, body) = Sms.deliver(phone_number, body)
end

require "net/http"

# Twilio, because the numbers here are all Indian ten digit mobiles.
#   bin/rails credentials:edit  ->  twilio: { account_sid:, auth_token:, from: }
# Without credentials the message goes to the log, which is how development and
# test stay offline.
module Sms
  def self.deliver(phone_number, body)
    return Rails.logger.info("[SMS] #{phone_number}: #{body}") if credentials.blank?

    uri = URI("https://api.twilio.com/2010-04-01/Accounts/#{credentials[:account_sid]}/Messages.json")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(credentials[:account_sid], credentials[:auth_token])
    request.set_form_data(From: credentials[:from], To: "+91#{phone_number}", Body: body)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    Rails.logger.warn("SMS #{response.code}: #{response.body}") unless response.is_a?(Net::HTTPSuccess)
  end

  def self.credentials = Rails.application.credentials.twilio
end

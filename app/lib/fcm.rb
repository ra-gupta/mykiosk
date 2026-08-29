require "net/http"

# Firebase Cloud Messaging HTTP v1. Needs credentials:
#   bin/rails credentials:edit  ->  fcm: { project_id:, client_email:, private_key: }
# Without them every call is a no-op, so development and test stay offline.
module Fcm
  OAUTH_URL = "https://oauth2.googleapis.com/token"
  SCOPE = "https://www.googleapis.com/auth/firebase.messaging"

  class << self
    def notify(tokens, title:, body:, data: {})
      return if tokens.blank? || credentials.blank?

      tokens.each { |token| send_message(token, title, body, data) }
    end

    private
      def credentials = Rails.application.credentials.fcm

      def send_message(token, title, body, data)
        message = {
          token:, notification: { title:, body: },
          data: data.transform_values(&:to_s),
          android: { priority: "high" }
        }
        uri = URI("https://fcm.googleapis.com/v1/projects/#{credentials[:project_id]}/messages:send")
        response = Net::HTTP.post(uri, { message: }.to_json,
          "Content-Type" => "application/json", "Authorization" => "Bearer #{access_token}")

        Rails.logger.warn("FCM #{response.code}: #{response.body}") unless response.is_a?(Net::HTTPSuccess)
        DeviceToken.where(token:).delete_all if response.code.to_i.in?([ 404, 400 ])
      end

      def access_token
        Rails.cache.fetch("fcm/access_token", expires_in: 50.minutes) do
          response = Net::HTTP.post_form(URI(OAUTH_URL),
            grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion: jwt)
          JSON.parse(response.body).fetch("access_token")
        end
      end

      def jwt
        now = Time.current.to_i
        claims = { iss: credentials[:client_email], scope: SCOPE, aud: OAUTH_URL, iat: now, exp: now + 3600 }
        payload = [ { alg: "RS256", typ: "JWT" }, claims ].map { |part| base64(part.to_json) }.join(".")
        key = OpenSSL::PKey::RSA.new(credentials[:private_key])

        "#{payload}.#{base64(key.sign(OpenSSL::Digest.new('SHA256'), payload))}"
      end

      def base64(bytes) = Base64.urlsafe_encode64(bytes, padding: false)
  end
end

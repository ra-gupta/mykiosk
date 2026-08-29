class User < ApplicationRecord
  OTP_VALIDITY = 5.minutes

  has_secure_password validations: false
  has_secure_password :otp, validations: false

  has_many :sessions, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :device_tokens, dependent: :destroy

  scope :owners_with_phone, -> { where(owner: true).where.not(phone_number: nil) }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :phone_number, with: ->(p) { p.gsub(/\D/, "").last(10) }

  validates :email_address, presence: true, uniqueness: true, unless: :phone_number
  validates :phone_number, presence: true, uniqueness: true, length: { is: 10 }, unless: :email_address
  validates :password, presence: { if: -> { email_address? && password_digest.blank? } },
                       length: { minimum: 8, allow_nil: true }, confirmation: true

  def self.authenticate(credentials)
    credentials = credentials.to_h.symbolize_keys

    if credentials[:phone_number].present?
      find_by(phone_number: normalize_value_for(:phone_number, credentials[:phone_number]))
        &.verify_otp(credentials[:code])
    elsif credentials.values_at(:email_address, :password).all?(&:present?)
      authenticate_by(credentials.slice(:email_address, :password))
    end
  end

  def self.start_phone_verification(phone_number)
    user = find_or_initialize_by(phone_number: normalize_value_for(:phone_number, phone_number))
    user.otp = format("%06d", SecureRandom.random_number(1_000_000))
    user.otp_sent_at = Time.current
    user.save!
    user.deliver_otp
    user
  end

  def verify_otp(code)
    return unless code.present? && otp_sent_at&.after?(OTP_VALIDITY.ago) && authenticate_otp(code.to_s)

    update!(otp: nil, otp_sent_at: nil)
    self
  end

  def deliver_otp
    SmsJob.perform_later(phone_number, "#{otp} is your MyKiosk code. It expires in 5 minutes.")
  end

  def display_name = email_address.presence || phone_number
end

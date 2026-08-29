class DeviceToken < ApplicationRecord
  belongs_to :user

  scope :owners, -> { joins(:user).where(users: { owner: true }) }

  def self.register(user, token) = find_or_initialize_by(token:).update!(user:)
end

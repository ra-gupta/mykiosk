ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def address_attributes(overrides = {})
      { recipient_name: "Rahul Gupta", phone_number: "9876543210", pincode: "560038",
        line1: "Flat 4B, Green Residency", line2: "8th Cross, Indiranagar",
        landmark: "opposite the water tank", city: "Bengaluru", state: "Karnataka" }.merge(overrides)
    end
  end
end

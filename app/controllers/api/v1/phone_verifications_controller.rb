module Api
  module V1
    class PhoneVerificationsController < BaseController
      skip_before_action :authenticate
      rate_limit to: 5, within: 3.minutes

      def create
        User.start_phone_verification(params[:phone_number])
        head :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end

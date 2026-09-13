module Api
  module V1
    module Owner
      class BaseController < Api::V1::BaseController
        before_action :require_owner

        private
          def require_owner
            render json: { error: "Owners only" }, status: :forbidden unless Current.user.owner?
          end
      end
    end
  end
end

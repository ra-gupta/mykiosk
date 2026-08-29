module Owner
  class BaseController < ApplicationController
    before_action :require_owner

    private
      def require_owner
        redirect_to root_path, alert: "Owners only." unless Current.user&.owner?
      end
  end
end

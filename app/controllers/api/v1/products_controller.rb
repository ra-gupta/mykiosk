module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate

      def index
        render json: Product.with_attached_photo.search(params[:q]).order(:name).map { |product| product_json(product) }
      end
    end
  end
end

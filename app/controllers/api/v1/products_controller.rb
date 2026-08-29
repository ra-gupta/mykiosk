module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate

      def index
        products = Product.order(:name)
        products = products.where("name LIKE ?", "%#{params[:q]}%") if params[:q].present?
        render json: products.as_json(only: %i[ id name price unit stock ])
      end
    end
  end
end

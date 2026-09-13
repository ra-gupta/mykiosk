module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate

      def index
        products = Product.with_attached_photo.order(:name)
        products = products.where("name LIKE ?", "%#{params[:q]}%") if params[:q].present?
        render json: products.map { |product| product_json(product) }
      end
    end
  end
end

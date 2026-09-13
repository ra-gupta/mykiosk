module Api
  module V1
    module Owner
      class ProductsController < BaseController
        # { product: { stock:, price:, mrp:, name:, unit: } } — any subset
        def update
          product = Product.find(params[:id])
          product.update!(params.require(:product).permit(:name, :price, :mrp, :unit, :stock))
          render json: product_json(product)
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end

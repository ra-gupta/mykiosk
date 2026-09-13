module Api
  module V1
    module Owner
      class ProductsController < BaseController
        # { product: { name:, unit:, price:, mrp:, stock: } }
        def create
          product = Product.create!(product_params)
          render json: product_json(product), status: :created
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
        end

        # Any subset of the fields above.
        def update
          product = Product.find(params[:id])
          product.update!(product_params)
          render json: product_json(product)
        rescue ActiveRecord::RecordInvalid => e
          render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
        end

        private
          def product_params = params.require(:product).permit(:name, :price, :mrp, :unit, :stock)
      end
    end
  end
end

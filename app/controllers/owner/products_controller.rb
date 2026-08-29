module Owner
  class ProductsController < BaseController
    before_action :set_product, only: %i[ edit update destroy ]

    def index
      @products = Product.order(:name)
    end

    def new
      @product = Product.new(unit: "1 kg", stock: 0)
    end

    def create
      @product = Product.new(product_params)
      return render :new, status: :unprocessable_entity unless @product.save

      redirect_to owner_products_path, notice: "#{@product.name} is on the shelf."
    end

    def edit
    end

    def update
      return render :edit, status: :unprocessable_entity unless @product.update(product_params)

      redirect_to owner_products_path, notice: "#{@product.name} updated."
    end

    def destroy
      @product.destroy!
      redirect_to owner_products_path, notice: "#{@product.name} removed."
    end

    private
      def set_product = @product = Product.find(params[:id])

      def product_params = params.require(:product).permit(:name, :price, :mrp, :unit, :stock, :photo)
  end
end

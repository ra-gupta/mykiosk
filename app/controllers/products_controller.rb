class ProductsController < ApplicationController
  allow_unauthenticated_access

  def index
    @products = Product.order(:name)
    @products = @products.where("name LIKE ?", "%#{params[:q]}%") if params[:q].present?
  end
end

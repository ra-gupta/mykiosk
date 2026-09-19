class ProductsController < ApplicationController
  allow_unauthenticated_access

  def index
    @products = Product.with_attached_photo.search(params[:q]).order(:name)
  end
end

class ProductsController < ApplicationController
    before_action :set_product, only: [:show, :update, :destroy]
  
    def index
      if params[:search].present?
        query = params[:search].downcase
        @products = Product.where("LOWER(name) LIKE ? OR LOWER(code) LIKE ?", "%#{query}%", "%#{query}%")
      else
        @products = Product.all
      end
  
      render json: @products
    end
  
    def show
      render json: @product
    end
  
    def create
      @product = Product.new(product_params)
  
      if @product.save
        render json: @product, status: :created
      else
        render json: @product.errors, status: :unprocessable_entity
      end
    end
  
    def update
      if @product.update(product_params)
        render json: @product
      else
        render json: @product.errors, status: :unprocessable_entity
      end
    end
  
    def destroy
      @product.destroy
      head :no_content
    end
  
    private
  
    def set_product
      @product = Product.find_by(id: params[:id])
      render json: { error: "Product not found" }, status: :not_found unless @product
    end
  
    def product_params
      params.require(:product).permit(:name, :code, :price)
    end
  end
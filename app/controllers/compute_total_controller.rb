class ComputeTotalController < ApplicationController
    def create
        product_codes = params[:product_codes] || []
        result = ComputeTotalService.new(product_codes).call

        render json: {
        total: result[:total],
        promotions: result[:promotions]
        }
    end
end

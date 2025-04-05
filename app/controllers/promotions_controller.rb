class PromotionsController < ApplicationController
    before_action :set_promotion, only: [ :show, :update, :destroy ]

    def index
        if params[:name].present?
          query = params[:name].downcase
          @promotions = Promotion.where("LOWER(name) LIKE ?", "%#{query}%")
        else
          @promotions = Promotion.all
        end

        render json: @promotions
    end

    def show
      render json: @promotion
    end

    def create
      @promotion = Promotion.new(promotion_params)

      if @promotion.save
        render json: @promotion, status: :created
      else
        render json: @promotion.errors, status: :unprocessable_entity
      end
    end

    def update
      if @promotion.update(promotion_params)
        render json: @promotion
      else
        render json: @promotion.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @promotion.destroy
      head :no_content
    end

    private

    def set_promotion
      @promotion = Promotion.find_by(id: params[:id])
      render json: { error: "Not found" }, status: :not_found unless @promotion
    end

    def promotion_params
      params.require(:promotion).permit(
        :name,
        :promotion_type,
        :product_id,
        :new_price,
        :discount_percentage,
        :trigger_quantity
      )
    end
end

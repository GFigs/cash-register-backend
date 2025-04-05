require 'rails_helper'

RSpec.describe "Checkouts API", type: :request do
  before(:each) do
    @green_tea = Product.create!(code: "GR1", name: "Green Tea", price: 3.11)
    @strawberry = Product.create!(code: "SR1", name: "Strawberries", price: 5.00)
    @coffee = Product.create!(code: "CF1", name: "Coffee", price: 11.23)

    Promotion.create!(
        name: "Buy One Get One Free - Green Tea",
        product: @green_tea,
        promotion_type: :bogof
    )

    Promotion.create!(
        name: "Bulk Discount - Strawberries (3 or more)",
        product: @strawberry,
        promotion_type: :change_price,
        new_price: 4.50,
        trigger_quantity: 3
    )

    Promotion.create!(
        name: "Coffee Multi Discount (3 or more)",
        product: @coffee,
        promotion_type: :percentual_discount,
        discount_percentage: 33.33,
        trigger_quantity: 3
    )
    end

    describe "POST /checkout" do
    it "returns correct total and promotions for GR1,GR1" do
        post "/checkout", params: {
        product_codes: [ "GR1", "GR1" ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["total"].to_f).to eq(3.11)
        expect(json["promotions"]).to include(
        a_hash_including(
            "description" => "Buy One Get One Free - Green Tea",
            "discount" => 3.11
        )
        )
    end

    it "returns correct total and promotions for SR1,SR1,GR1,SR1" do
        post "/checkout", params: {
        product_codes: [ "SR1", "SR1", "GR1", "SR1" ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["total"].to_f).to eq(16.61)
        expect(json["promotions"]).to include(
        a_hash_including(
            "description" => "Bulk Discount - Strawberries (3 or more)",
            "discount" => 1.50
        )
        )
    end

    it "returns correct total and promotions for GR1,CF1,SR1,CF1,CF1" do
        post "/checkout", params: {
        product_codes: [ "GR1", "CF1", "SR1", "CF1", "CF1" ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["total"].to_f).to eq(30.57)
        expect(json["promotions"]).to include(
        a_hash_including(
            "description" => "Bulk Discount - Coffee Multi Discount (3 or more)",
            "discount" => 11.23
        )
        )
    end
  end
end

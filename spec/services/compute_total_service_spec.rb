require 'rails_helper'

RSpec.describe ComputeTotalService do
  before(:all) do
    Product.destroy_all
    Promotion.destroy_all
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

  describe "#call" do
    subject { described_class.new(product_codes).call }

    context "when basket is GR1,GR1" do
      let(:product_codes) { [ "GR1", "GR1" ] }

      it "returns total with BOGO promotion on Green Tea" do
        result = subject
        expect(result[:total]).to eq(3.11)
        expect(result[:promotions]).to include(
          description: "Buy One Get One Free - Green Tea",
          discount: 3.11
        )
      end
    end

    context "when basket is SR1,SR1,GR1,SR1" do
      let(:product_codes) { [ "SR1", "SR1", "GR1", "SR1" ] }

      it "returns total with bulk discount on Strawberries" do
        result = subject
        expect(result[:total]).to eq(16.61)
        expect(result[:promotions]).to include(
          description: "Bulk Discount - Strawberries (3 or more)",
          discount: 1.50
        )
      end
    end

    context "when basket is GR1,CF1,SR1,CF1,CF1" do
      let(:product_codes) { [ "GR1", "CF1", "SR1", "CF1", "CF1" ] }

      it "returns total with coffee discount" do
        result = subject
        expect(result[:total]).to eq(30.57)
        expect(result[:promotions]).to include(
          description: "Bulk Discount - Coffee Multi Discount (3 or more)",
          discount: 11.23
        )
      end
    end
  end
end

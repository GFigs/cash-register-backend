require 'rails_helper'

RSpec.describe Product, type: :model do
  describe "validations" do
    it "validate presence of requide fields" do
      should validate_presence_of(:code)
      should validate_presence_of(:name)
      should validate_presence_of(:price)
    end
    it "validate uniqueness of code" do
      should validate_uniqueness_of(:code)
    end
  end

  describe "#price_format" do
    it "is invalid if price has more than 2 decimal digits" do
      product = Product.new(code: "2DD", name: "too many decimal", price: 10.123)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include('must have at most 2 decimal places')
    end

    it "is invalid if price has more than 6 digits before decimal" do
      product = Product.new(code: "MT6", name: "big price", price: 1_000_000.00)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("must be less than 1,000,000")
    end

    it "is valid if price matches range and format" do
      product = Product.new(code: "OK", name: "good price", price: 999.00)
      expect(product).to be_valid
    end
  end
end

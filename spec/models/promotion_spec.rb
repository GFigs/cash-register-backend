require 'rails_helper'

RSpec.describe Promotion, type: :model do
  describe "associations" do
    it { should belong_to(:product) }
  end

  describe "validations" do
    it "standard validations" do
      should validate_presence_of(:name)
      should validate_presence_of(:product_id)
      should validate_presence_of(:promotion_type)
      should define_enum_for(:promotion_type).with_values([:bogof, :change_price, :percentual_discount])
    end
  end

  describe "validations by promotion_type" do
    let(:product) { build_stubbed(:product) }

    context "when promotion_type is change_price" do 
      subject do
        described_class.new(
          name: "Change Price Promo",
          product: product,
          promotion_type: :change_price
        )
      end

      before { subject.validate }

      it "requires trigger_quantity" do
        expect(subject.errors[:trigger_quantity]).to include("must be present")
      end

      it "requires new_price" do
        expect(subject.errors[:new_price]).to include("must be present")
      end

      it "is invalid if price has more than 6 digits before decimal" do
        subject.new_price = 1_000_000
        subject.trigger_quantity = 3
        subject.validate
        expect(subject.errors[:new_price]).to include("must be less than 1,000,000")
      end

      it "is invalid if price has more than 2 decimal digits" do
        subject.new_price = 99.999
        subject.trigger_quantity = 3
        subject.validate
        expect(subject.errors[:new_price]).to include("must have at most 2 decimal places")
      end

      it "is valid with trigger_quantity and new_price in correct format" do
        subject.new_price = 99.99
        subject.trigger_quantity = 3
        expect(subject).to be_valid
      end
    end

    context "when promotion_type is percentual_discount" do 
      subject do
        described_class.new(
          name: "Percentual Discount Promo",
          product: product,
          promotion_type: :percentual_discount
        )
      end

      before { subject.validate }

      it "requires trigger_quantity" do
        expect(subject.errors[:trigger_quantity]).to include("must be present")
      end

      it "requires discount_percentage" do
        expect(subject.errors[:discount_percentage]).to include("must be present")
      end

      it "is invalid if discount_percentage is 0" do
        subject.discount_percentage = 0
        subject.trigger_quantity = 3
        subject.validate
        expect(subject.errors[:discount_percentage]).to include("must be greater than or equal to 0.01")
      end
      
      it "is invalid if discount_percentage is greater than 99.99" do
        subject.discount_percentage = 100
        subject.trigger_quantity = 3
        subject.validate
        expect(subject.errors[:discount_percentage]).to include("must be less than or equal to 99.99")
      end

      it "is valid with trigger_quantity and discount_percentage in correct format" do
        subject.discount_percentage = 25.50
        subject.trigger_quantity = 4
        expect(subject).to be_valid
      end
    end

    context "when promotion_type is bogof" do 
      subject do
        described_class.new(
          name: "BOGOF Promo",
          product: product,
          promotion_type: :bogof
        )
      end

      before { subject.validate }

      it "does not require trigger_quantity" do
        expect(subject.errors[:trigger_quantity]).to be_empty
      end

      it "does not require new_price" do
        expect(subject.errors[:new_price]).to be_empty
      end

      it "does not require discount_percentage" do
        expect(subject.errors[:discount_percentage]).to be_empty
      end
    end
  end
end

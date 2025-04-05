require 'rails_helper'

RSpec.describe "Promotions API", type: :request do
  let!(:product) { create(:product, name: "Green Tea", code: "GR1", price: 3.11) }

  let!(:bogof_promo) { create(:promotion, name: "BOGOF Promo", product: product, promotion_type: :bogof) }
  let!(:discount_promo) { create(:promotion, name: "Summer Discount", product: product, promotion_type: :percentual_discount, discount_percentage: 15, trigger_quantity: 3) }

  let(:valid_bogof_attributes) do
    {
      name: "2x1 Green Tea",
      promotion_type: "bogof",
      product_id: product.id
    }
  end

  let(:valid_change_price_attributes) do
    {
      name: "New Price Deal",
      promotion_type: "change_price",
      product_id: product.id,
      new_price: 2.99,
      trigger_quantity: 2
    }
  end

  let(:valid_percentual_discount_attributes) do
    {
      name: "Spring Discount",
      promotion_type: "percentual_discount",
      product_id: product.id,
      discount_percentage: 20,
      trigger_quantity: 2
    }
  end

  let(:invalid_attributes) do
    {
      name: "",
      promotion_type: "",
      product_id: nil
    }
  end

  describe "GET /promotions" do
    it "returns all promotions" do
      get "/promotions"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to be >= 2
    end

    it "returns promotions matching name" do
      get "/promotions", params: { name: "summer" }
      result = JSON.parse(response.body)

      expect(result.length).to eq(1)
      expect(result.first["name"]).to eq("Summer Discount")
    end

    it "returns an empty array when no promotion matches the search" do
      get "/promotions", params: { name: "no_match" }
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "GET /promotions/:id" do
    it "returns the requested promotion" do
      get "/promotions/#{bogof_promo.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("BOGOF Promo")
    end

    it "returns 404 for invalid promotion id" do
      get "/promotions/9999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /promotions" do
    it "creates a bogof promotion with valid attributes" do
      expect {
        post "/promotions", params: { promotion: valid_bogof_attributes }
      }.to change(Promotion, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "creates a change_price promotion with required attributes" do
      post "/promotions", params: { promotion: valid_change_price_attributes }

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data["promotion_type"]).to eq("change_price")
      expect(data["new_price"]).to eq("2.99")
    end

    it "creates a percentual_discount promotion with required attributes" do
      post "/promotions", params: { promotion: valid_percentual_discount_attributes }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["promotion_type"]).to eq("percentual_discount")
      expect(json["discount_percentage"]).to eq("20.0")
      expect(json["trigger_quantity"]).to eq(2)
    end

    it "does not create promotion with invalid attributes" do
      post "/promotions", params: { promotion: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end

    it "fails to create percentual_discount without required fields" do
      incomplete_attrs = valid_percentual_discount_attributes.except(:discount_percentage, :trigger_quantity)

      post "/promotions", params: { promotion: incomplete_attrs }

      expect(response).to have_http_status(:unprocessable_entity)
      errors = JSON.parse(response.body)["errors"]

      expect(errors).to include("Discount percentage must be present")
      expect(errors).to include("Trigger quantity must be present")
    end
  end

  describe "PUT /promotions/:id" do
    it "updates the promotion with valid attributes" do
      put "/promotions/#{bogof_promo.id}", params: { promotion: { name: "Updated Promo" } }

      expect(response).to have_http_status(:ok)
      expect(bogof_promo.reload.name).to eq("Updated Promo")
    end

    it "does not update with invalid attributes" do
      put "/promotions/#{bogof_promo.id}", params: { promotion: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end

    it "returns 404 if promotion not found" do
      put "/promotions/9999", params: { promotion: valid_bogof_attributes }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /promotions/:id" do
    it "deletes the promotion" do
      expect {
        delete "/promotions/#{discount_promo.id}"
      }.to change(Promotion, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 if promotion not found" do
      delete "/promotions/9999"
      expect(response).to have_http_status(:not_found)
    end
  end
end

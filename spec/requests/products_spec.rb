require 'rails_helper'

RSpec.describe "Products API", type: :request do
  let!(:product) { create(:product, name: "Green Tea", code: "GR1", price: 3.11) }
  let!(:strawberries) { create(:product, name: "Strawberries", code: "SR1", price: 5.00) }

  let(:valid_attributes) { { name: "Coffee", code: "CF1", price: 11.23 } }
  let(:invalid_attributes) { { name: "", code: "", price: nil } }

  describe "GET /products" do
    it "returns all products" do
      get "/products"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to be >= 2
    end

    it "returns products matching name" do
        get "/products", params: { search: "green" }
        result = JSON.parse(response.body)

        expect(result.length).to eq(1)
        expect(result.first["name"]).to eq("Green Tea")
    end

    it "returns products matching code" do
        get "/products", params: { search: "sr1" }
        result = JSON.parse(response.body)

        expect(result.length).to eq(1)
        expect(result.first["code"]).to eq("SR1")
    end

    it "returns an empty array when no product matches the search" do
      get "/products", params: { search: "no_match" }
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "GET /products/:id" do
    it "returns the requested product" do
      get "/products/#{product.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("Green Tea")
    end

    it "returns 404 for invalid product id" do
      get "/products/9999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /products" do
    it "creates a new product with valid attributes" do
      expect {
        post "/products", params: { product: valid_attributes }
      }.to change(Product, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "does not create product with invalid attributes" do
      post "/products", params: { product: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /products/:id" do
    it "updates the product with valid attributes" do
      put "/products/#{product.id}", params: { product: { price: 4.99 } }
      expect(response).to have_http_status(:ok)
      expect(product.reload.price).to eq(4.99)
    end

    it "does not update with invalid attributes" do
      put "/products/#{product.id}", params: { product: { price: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 if product not found" do
      put "/products/9999", params: { product: valid_attributes }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /products/:id" do
    it "deletes the product" do
      expect {
        delete "/products/#{product.id}"
      }.to change(Product, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 if product not found" do
      delete "/products/9999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
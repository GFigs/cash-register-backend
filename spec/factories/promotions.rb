FactoryBot.define do
  factory :promotion do
    name { "MyString" }
    product { "Test Product" }
    promotion_type { 1 }
    trigger_quantity { 1 }
    new_price { "9.99" }
    discount_percentage { "9.99" }
  end
end

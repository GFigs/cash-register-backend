# Borramos todo para evitar duplicados
Promotion.destroy_all
Product.destroy_all

puts "Cleaned up old data"

# Base products
products = [
  { code: 'GR1', name: 'Green Tea', price: 3.11 },
  { code: 'SR1', name: 'Strawberries', price: 5.00 },
  { code: 'CF1', name: 'Coffee', price: 11.23 }
]

products.each do |attrs|
  Product.create!(attrs)
end

puts "✅ Created products"

# Products by code
green_tea     = Product.find_by!(code: 'GR1')
strawberries  = Product.find_by!(code: 'SR1')
coffee        = Product.find_by!(code: 'CF1')

# Create promotions
Promotion.create!(
  name: "Buy One Get One Free Green Tea",
  product: green_tea,
  promotion_type: :bogof
)

Promotion.create!(
  name: "Bulk Discount for Strawberries",
  product: strawberries,
  promotion_type: :change_price,
  new_price: 4.50,
  trigger_quantity: 3
)

Promotion.create!(
  name: "Coffee Bulk Percentage Discount",
  product: coffee,
  promotion_type: :percentual_discount,
  discount_percentage: 33.33,
  trigger_quantity: 3
)

puts "Seeds loaded successfully!"

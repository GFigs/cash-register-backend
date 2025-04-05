class ComputeTotalService
    def initialize(product_codes)
      @product_codes = product_codes
      @products = Product.where(code: product_codes)
      @item_counts = Hash.new(0)
      @product_codes.each { |code| @item_counts[code] += 1 }
      @total = 0
      @promotions_applied = []
    end
  
    def call
      calculate_base_total
      apply_promotions
  
      {
        total: @total.round(2),
        promotions: @promotions_applied
      }
    end
  
    private
  
    def calculate_base_total
      @product_codes.each do |code|
        product = @products.find { |p| p.code == code }
        @total += product.price if product
      end
    end
  
    def apply_promotions
        all_promotions = Promotion.all
      
        @products.each do |product|
          quantity = @item_counts[product.code]
          next if quantity.zero?
      
          applicable_promos = all_promotions.select { |promo| promo.product_id == product.id }
      
          applicable_promos.each do |promo|
            case promo.promotion_type.to_sym
            when :bogof
              apply_bogof(product, quantity)
            when :change_price
              apply_bulk_price(product, quantity, promo)
            when :percentual_discount
              apply_percent_discount(product, quantity, promo)
            end
          end
        end
    end
  
    def apply_bogof(product, quantity)
      free_items = quantity / 2
      discount = free_items * product.price
      return if discount.zero?
  
      apply_discount(
        description: "Buy One Get One Free - #{product.name}",
        discount: discount
      )
    end
  
    def apply_bulk_price(product, quantity, promo)
      return if quantity < promo.trigger_quantity
  
      normal_total = quantity * product.price
      new_total = quantity * promo.new_price
      discount = normal_total - new_total
      return if discount.zero?
  
      apply_discount(
        description: "Bulk Discount - #{product.name} (#{promo.trigger_quantity} or more)",
        discount: discount
      )
    end
  
    def apply_percent_discount(product, quantity, promo)
      return if quantity < promo.trigger_quantity
  
      fraction = approximate_fraction(promo.discount_percentage)
      total_price = quantity * product.price
      discount = (total_price * fraction).to_f.round(2)
      return if discount.zero?
  
      apply_discount(
        description: "Bulk Discount - #{promo.name}",
        discount: discount
      )
    end
  
    def apply_discount(description:, discount:)
      @total -= discount
      @promotions_applied << {
        description: description,
        discount: discount.round(2).to_f
      }
    end
  
    def approximate_fraction(percentage)
      {
        33.33 => Rational(1, 3),
        66.67 => Rational(2, 3),
        16.67 => Rational(1, 6),
        83.33 => Rational(5, 6),
        11.11 => Rational(1, 9)
      }[percentage.to_f.round(2)] || (percentage / 100.0)
    end
  end

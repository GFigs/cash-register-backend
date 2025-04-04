class Product < ApplicationRecord
    #standard validations
    validates :code, presence: true, uniqueness: true
    validates :name, presence: true
    validates :price, presence: true

    #price format validation
    validate :price_format

    private

    def price_format 
        return if price.nil?

        if price.to_d.to_s('F') =~ /\.\d{3,}/
            errors.add(:price, 'must have at most 2 decimal places')
        end

        if price >= 1_000_000
            errors.add(:price, 'must be less than 1,000,000')
        end
    end
end

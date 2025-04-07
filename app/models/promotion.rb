class Promotion < ApplicationRecord
  belongs_to :product

  enum :promotion_type, [ :bogof, :change_price, :percentual_discount ]

  # standar validations
  validates :name, :product_id, :promotion_type, presence: true

  validates :discount_percentage,
            numericality: {
              greater_than_or_equal_to: 0.01,
              less_than_or_equal_to: 99.99
            },
            allow_nil: true

  validates :new_price,
            numericality: {
              greater_than: 0,
              less_than: 1_000_000
            },
            allow_nil: true

  # promotion_type specific validations
  validate :validate_type_specific_fields

  private

  def validate_type_specific_fields
    return if promotion_type.blank?

    case promotion_type.to_sym
    when :change_price
      errors.add(:new_price, "must be present") if new_price.blank?
      errors.add(:trigger_quantity, "must be present") if trigger_quantity.blank?
    when :percentual_discount
      errors.add(:discount_percentage, "must be present") if discount_percentage.blank?
      errors.add(:trigger_quantity, "must be present") if trigger_quantity.blank?
    end
  end
end

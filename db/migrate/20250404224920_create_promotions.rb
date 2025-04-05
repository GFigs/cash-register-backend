class CreatePromotions < ActiveRecord::Migration[8.0]
  def change
    create_table :promotions do |t|
      t.string :name
      t.references :product, null: false, foreign_key: true
      t.integer :promotion_type
      t.integer :trigger_quantity
      t.decimal :new_price, scale: 2
      t.decimal :discount_percentage,

      t.timestamps
    end
  end
end

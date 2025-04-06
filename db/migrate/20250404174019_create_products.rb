class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :code
      t.string :name
      t.decimal :price, precision: 8, scale: 2

      t.timestamps
    end

    add_index :products, :code, unique: true
  end
end

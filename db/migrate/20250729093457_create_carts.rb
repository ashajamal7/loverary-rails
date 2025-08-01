class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.decimal :total_price, precision: 10, scale: 2

      t.timestamps

    end

  end
end
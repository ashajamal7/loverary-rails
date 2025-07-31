class CreateShippings < ActiveRecord::Migration[8.0]
  def change
    create_table :shippings do |t|
      t.references :order, null: false, foreign_key: true
      t.string :address
      t.integer :status
      t.string :tracking_code
      t.datetime :shipped_at

      t.timestamps
    end
  end
end

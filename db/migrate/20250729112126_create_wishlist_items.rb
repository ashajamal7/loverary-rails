class CreateWishlistItems < ActiveRecord::Migration[8.0]
  def change
    create_table :wishlist_items do |t|
      t.references :wishlist, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.datetime :added_at

      t.timestamps
    end
  end
end
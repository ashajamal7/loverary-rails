class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :isbn
      t.integer :stock
      t.string :title
      t.references :author, null: false, foreign_key: true
      t.text :summary
      t.decimal :price
      t.string :cover_url

      t.timestamps
    end
  end
end

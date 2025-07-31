class AddDetailsToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :published_date, :datetime
    add_column :books, :edition, :integer
    add_column :books, :language, :string, null: false
    add_column :books, :page_count, :integer, null: false
  end
end

class AddAverageRatingToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :average_rating, :decimal, precision: 3, scale: 2
  end
end

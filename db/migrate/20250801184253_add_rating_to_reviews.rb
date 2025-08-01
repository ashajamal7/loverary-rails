class AddRatingToReviews < ActiveRecord::Migration[8.0]
  def change
    add_column :reviews, :rating, :integer
  end
end

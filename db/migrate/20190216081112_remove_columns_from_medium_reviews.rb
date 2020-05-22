class RemoveColumnsFromMediumReviews < ActiveRecord::Migration[5.1]
  def change
    remove_column :medium_reviews, :name
    remove_column :medium_reviews, :url
    remove_column :medium_reviews, :description
  end
end

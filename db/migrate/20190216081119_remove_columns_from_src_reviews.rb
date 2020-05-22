class RemoveColumnsFromSrcReviews < ActiveRecord::Migration[5.1]
  def change
    remove_column :src_reviews, :name
    remove_column :src_reviews, :url
    remove_column :src_reviews, :description
  end
end

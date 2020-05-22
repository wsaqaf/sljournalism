class RemoveColumnsFromClaimReviews < ActiveRecord::Migration[5.1]
  def change
    remove_column :claim_reviews, :name
    remove_column :claim_reviews, :title
    remove_column :claim_reviews, :url
    remove_column :claim_reviews, :description
  end
end

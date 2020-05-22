class AddUserIdToReviews < ActiveRecord::Migration[5.1]
  def change
    add_column :medium_reviews, :user_id, :integer
    add_column :src_reviews, :user_id, :integer
    add_column :claim_reviews, :user_id, :integer
  end
end

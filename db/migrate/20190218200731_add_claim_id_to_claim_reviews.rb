class AddClaimIdToClaimReviews < ActiveRecord::Migration[5.1]
  def change
    add_column :claim_reviews, :claim_id, :integer
  end
end

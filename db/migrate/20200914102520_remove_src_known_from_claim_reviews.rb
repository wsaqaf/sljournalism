class RemoveSrcKnownFromClaimReviews < ActiveRecord::Migration[5.2]
  def change
    remove_column :claim_reviews, :src_known, :string
  end
end

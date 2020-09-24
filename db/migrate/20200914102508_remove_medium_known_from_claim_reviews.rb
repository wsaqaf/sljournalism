class RemoveMediumKnownFromClaimReviews < ActiveRecord::Migration[5.2]
  def change
    remove_column :claim_reviews, :medium_known, :string
  end
end

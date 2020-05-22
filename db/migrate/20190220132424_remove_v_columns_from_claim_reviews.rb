class RemoveVColumnsFromClaimReviews < ActiveRecord::Migration[5.1]
  def change
    remove_column :claim_reviews, :has_video
    remove_column :claim_reviews, :note_has_video
  end
end

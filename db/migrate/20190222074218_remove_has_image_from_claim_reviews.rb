class RemoveHasImageFromClaimReviews < ActiveRecord::Migration[5.1]
  def change
    remove_column :claim_reviews, :has_image
    remove_column :claim_reviews, :note_has_image    
  end
end

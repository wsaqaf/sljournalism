class RemoveNoteImgReviewStartedFromClaimReviews < ActiveRecord::Migration[5.2]
  def change
    remove_column :claim_reviews, :note_img_review_started, :string
  end
end

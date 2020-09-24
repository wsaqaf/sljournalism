class RemoveNoteVidReviewStartedFromClaimReviews < ActiveRecord::Migration[5.2]
  def change
    remove_column :claim_reviews, :note_vid_review_started, :string
  end
end

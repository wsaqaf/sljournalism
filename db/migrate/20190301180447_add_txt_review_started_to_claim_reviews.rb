class AddTxtReviewStartedToClaimReviews < ActiveRecord::Migration[5.1]
  def change
    add_column :claim_reviews, :txt_review_started, :integer
  end
end

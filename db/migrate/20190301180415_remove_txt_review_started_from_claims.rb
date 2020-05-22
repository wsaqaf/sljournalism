class RemoveTxtReviewStartedFromClaims < ActiveRecord::Migration[5.1]
  def change
    remove_column :claims, :txt_review_started
  end
end

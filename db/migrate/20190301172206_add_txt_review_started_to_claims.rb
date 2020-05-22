class AddTxtReviewStartedToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :txt_review_started, :integer
  end
end

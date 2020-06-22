class AddAdminAssessmentToClaimReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :claim_reviews, :blockchain_assessment, :integer
    add_column :claim_reviews, :blockchain_assessment_rationale, :string
    add_column :claim_reviews, :blockchain_assessment_admin_id, :string
    add_column :claim_reviews, :blockchain_assessment_time, :datetime
    add_column :claim_reviews, :blockchain_assessment_tx, :string
  end
end

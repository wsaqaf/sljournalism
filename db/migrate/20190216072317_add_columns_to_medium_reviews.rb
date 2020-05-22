class AddColumnsToMediumReviews < ActiveRecord::Migration[5.1]
  def change
    add_column :medium_reviews, :medium_review_started, :integer
    add_column :medium_reviews, :medium_is_blacklisted, :integer
    add_column :medium_reviews, :medium_failed_factcheck_before, :integer
    add_column :medium_reviews, :medium_has_poor_security, :integer
    add_column :medium_reviews, :medium_whois_info_discrepency, :integer
    add_column :medium_reviews, :medium_hosting_discrepency, :integer
    add_column :medium_reviews, :medium_is_biased, :integer
    add_column :medium_reviews, :medium_is_poorly_ranked, :integer
    add_column :medium_reviews, :medium_is_not_liable, :integer
    add_column :medium_reviews, :medium_lacks_flagging_means, :integer
    add_column :medium_reviews, :medium_other_problems, :text
    add_column :medium_reviews, :medium_review_verdict, :integer
    add_column :medium_reviews, :medium_review_description, :text
    add_column :medium_reviews, :medium_review_sharing_mode, :integer
    add_column :medium_reviews, :medium_review_is_completed, :boolean
    add_column :medium_reviews, :note_medium_is_blacklisted, :string
    add_column :medium_reviews, :note_medium_failed_factcheck_before, :string
    add_column :medium_reviews, :note_medium_has_poor_security, :string
    add_column :medium_reviews, :note_medium_whois_info_discrepency, :string
    add_column :medium_reviews, :note_medium_hosting_discrepency, :string
    add_column :medium_reviews, :note_medium_is_biased, :string
    add_column :medium_reviews, :note_medium_is_poorly_ranked, :string
    add_column :medium_reviews, :note_medium_is_not_liable, :string
    add_column :medium_reviews, :note_medium_lacks_flagging_means, :string
    add_column :medium_reviews, :note_medium_other_problems, :string
    add_column :medium_reviews, :note_medium_review_verdict, :string
    add_column :medium_reviews, :note_medium_review_description, :string
    add_column :medium_reviews, :note_medium_review_sharing_mode, :string

    add_index :medium_reviews, :name, unique: true
    add_index :medium_reviews, :medium_id, unique: true
    add_index :medium_reviews, :medium_review_verdict
    add_index :medium_reviews, :medium_review_sharing_mode

  end
end

class AddColumnsToSrcReviews < ActiveRecord::Migration[5.1]
  def change
    add_column :src_reviews, :src_review_started, :integer
    add_column :src_reviews, :src_lacks_proper_credentials, :integer
    add_column :src_reviews, :src_failed_factcheck_before, :integer
    add_column :src_reviews, :src_has_poor_writing_history, :integer
    add_column :src_reviews, :src_supported_by_trolls, :integer
    add_column :src_reviews, :src_difficult_to_locate, :integer
    add_column :src_reviews, :src_other_problems, :integer
    add_column :src_reviews, :src_review_verdict, :integer
    add_column :src_reviews, :src_review_description, :text
    add_column :src_reviews, :src_review_sharing_mode, :integer
    add_column :src_reviews, :src_review_is_completed, :boolean
    add_column :src_reviews, :note_src_lacks_proper_credentials, :string
    add_column :src_reviews, :note_src_failed_factcheck_before, :string
    add_column :src_reviews, :note_src_has_poor_writing_history, :string
    add_column :src_reviews, :note_src_supported_by_trolls, :string
    add_column :src_reviews, :note_src_difficult_to_locate, :string
    add_column :src_reviews, :note_src_other_problems, :string
    add_column :src_reviews, :note_src_review_verdict, :string
    add_column :src_reviews, :note_src_review_description, :string
    add_column :src_reviews, :note_src_review_sharing_mode, :string

    add_index :src_reviews, :name, unique: true
    add_index :src_reviews, :src_id, unique: true
    add_index :src_reviews, :src_review_verdict
    add_index :src_reviews, :src_review_sharing_mode

  end
end

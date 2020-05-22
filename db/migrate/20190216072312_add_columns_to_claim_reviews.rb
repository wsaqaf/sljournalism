class AddColumnsToClaimReviews < ActiveRecord::Migration[5.1]
  def change
    add_column :claim_reviews, :medium_known, :integer
    add_column :claim_reviews, :src_known, :integer
    add_column :claim_reviews, :has_image, :integer
    add_column :claim_reviews, :img_review_started, :integer
    add_column :claim_reviews, :has_video, :integer
    add_column :claim_reviews, :vid_review_started, :integer
    add_column :claim_reviews, :img_old, :integer
    add_column :claim_reviews, :img_forensic_discrepency, :integer
    add_column :claim_reviews, :img_metadata_discrepency, :integer
    add_column :claim_reviews, :img_logical_discrepency, :integer
    add_column :claim_reviews, :vid_old, :integer
    add_column :claim_reviews, :vid_forensic_discrepency, :integer
    add_column :claim_reviews, :vid_metadata_discrepency, :integer
    add_column :claim_reviews, :vid_audio_discrepency, :integer
    add_column :claim_reviews, :vid_logical_discrepency, :integer
    add_column :claim_reviews, :txt_unreliable_news_content, :integer
    add_column :claim_reviews, :txt_insufficient_verifiable_srcs, :integer
    add_column :claim_reviews, :txt_has_clickbait, :integer
    add_column :claim_reviews, :txt_poor_language, :integer
    add_column :claim_reviews, :txt_crowds_distance_discrepency, :integer
    add_column :claim_reviews, :txt_author_offers_little_evidence, :integer
    add_column :claim_reviews, :txt_reliable_sources_disapprove, :integer
    add_column :claim_reviews, :review_verdict, :integer
    add_column :claim_reviews, :review_description, :text
    add_column :claim_reviews, :review_sharing_mode, :integer
    add_column :claim_reviews, :review_is_complete, :boolean
    add_column :claim_reviews, :review_published_url, :text
    add_column :claim_reviews, :note_has_image, :string
    add_column :claim_reviews, :note_has_video, :string
    add_column :claim_reviews, :note_img_review_started, :string
    add_column :claim_reviews, :note_img_old, :string
    add_column :claim_reviews, :note_img_forensic_discrepency, :string
    add_column :claim_reviews, :note_img_metadata_discrepency, :string
    add_column :claim_reviews, :note_img_logical_discrepency, :string
    add_column :claim_reviews, :note_vid_review_started, :string
    add_column :claim_reviews, :note_vid_old, :string
    add_column :claim_reviews, :note_vid_forensic_discrepency, :string
    add_column :claim_reviews, :note_vid_metadata_discrepency, :string
    add_column :claim_reviews, :note_vid_audio_discrepency, :string
    add_column :claim_reviews, :note_vid_logical_discrepency, :string
    add_column :claim_reviews, :note_txt_unreliable_news_content, :string
    add_column :claim_reviews, :note_txt_insufficient_verifiable_srcs, :string
    add_column :claim_reviews, :note_txt_has_clickbait, :string
    add_column :claim_reviews, :note_txt_poor_language, :string
    add_column :claim_reviews, :note_txt_crowds_distance_discrepency, :string
    add_column :claim_reviews, :note_txt_author_offers_little_evidence, :string
    add_column :claim_reviews, :note_txt_reliable_sources_disapprove, :string
    add_column :claim_reviews, :note_review_verdict, :string
    add_column :claim_reviews, :note_review_description, :string
    add_column :claim_reviews, :note_review_sharing_mode, :string
    add_column :claim_reviews, :note_review_published_url, :string

    add_index :claim_reviews, :title, unique: true
    add_index :claim_reviews, :claim_id, unique: true
    add_index :claim_reviews, :review_verdict

  end
end

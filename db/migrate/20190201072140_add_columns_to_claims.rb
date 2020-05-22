class AddColumnsToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :img_old, :tinyint
    add_column :claims, :img_forensic_discrepency, :tinyint
    add_column :claims, :img_metadata_discrepency, :tinyint
    add_column :claims, :img_logical_discrepency, :tinyint
    add_column :claims, :vid_old, :tinyint
    add_column :claims, :vid_forensic_discrepency, :tinyint
    add_column :claims, :vid_metadata_discrepency, :tinyint
    add_column :claims, :vid_audio_discrepency, :tinyint
    add_column :claims, :vid_logical_discrepency, :tinyint
    add_column :claims, :txt_unreliable_news_content, :tinyint
    add_column :claims, :txt_insufficient_verifiable_srcs, :tinyint
    add_column :claims, :txt_has_clickbait, :tinyint
    add_column :claims, :txt_poor_language, :tinyint
    add_column :claims, :txt_crowds_distance_discrepency, :tinyint
    add_column :claims, :txt_author_offers_little_evidence, :tinyint
    add_column :claims, :txt_reliable_sources_disapprove, :tinyint
    add_column :claims, :review_verdict, :tinyint
    add_column :claims, :review_description, :text
    add_column :claims, :review_sharing_mode, :tinyint
    add_column :claims, :review_is_complete, :boolean
    add_column :claims, :review_published_url, :text
  end
end

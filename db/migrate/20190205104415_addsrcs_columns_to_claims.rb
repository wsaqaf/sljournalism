class AddsrcsColumnsToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :src_lacks_proper_credentials, :tinyint
    add_column :claims, :src_failed_factcheck_before, :tinyint
    add_column :claims, :src_has_poor_writing_history, :tinyint
    add_column :claims, :src_supported_by_trolls, :tinyint
    add_column :claims, :src_difficult_to_locate, :tinyint
    add_column :claims, :src_other_problems, :tinyint
    add_column :claims, :src_review_verdict, :tinyint
    add_column :claims, :src_review_description, :text
    add_column :claims, :src_review_sharing_mode, :tinyint
    add_column :claims, :src_review_is_completed, :boolean
  end
end

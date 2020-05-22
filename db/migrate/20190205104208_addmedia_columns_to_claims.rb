class AddmediaColumnsToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :medium_is_blacklisted, :tinyint
    add_column :claims, :medium_failed_factcheck_before, :tinyint
    add_column :claims, :medium_has_poor_security, :tinyint
    add_column :claims, :medium_whois_info_discrepency, :tinyint
    add_column :claims, :medium_hosting_discrepency, :tinyint
    add_column :claims, :medium_is_biased, :tinyint
    add_column :claims, :medium_is_poorly_ranked, :tinyint
    add_column :claims, :medium_is_not_liable, :tinyint
    add_column :claims, :medium_lacks_flagging_means, :tinyint
    add_column :claims, :medium_other_problems, :text
    add_column :claims, :medium_review_verdict, :tinyint
    add_column :claims, :medium_review_description, :text
    add_column :claims, :medium_review_sharing_mode, :tinyint
    add_column :claims, :medium_review_is_completed, :boolean
  end
end

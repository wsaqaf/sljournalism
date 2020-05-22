class AddColumnsToMedia < ActiveRecord::Migration[5.1]
  def change
    add_column :media, :type, :tinyint
    add_column :media, :is_blacklisted, :tinyint
    add_column :media, :failed_factcheck_before, :tinyint
    add_column :media, :has_poor_security, :tinyint
    add_column :media, :whois_info_discrepency, :tinyint
    add_column :media, :hosting_discrepency, :tinyint
    add_column :media, :is_biased, :tinyint
    add_column :media, :is_poorly_ranked, :tinyint
    add_column :media, :is_not_liable, :tinyint
    add_column :media, :lacks_flagging_means, :tinyint
    add_column :media, :other_problems, :text
    add_column :media, :review_verdict, :tinyint
    add_column :media, :review_description, :text
    add_column :media, :review_sharing_mode, :tinyint
    add_column :media, :review_is_completed, :boolean
  end
end

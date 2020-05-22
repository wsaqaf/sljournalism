class RemoveColumnsFromMedia < ActiveRecord::Migration[5.1]
  def change
    remove_column :media, :is_blacklisted
    remove_column :media, :failed_factcheck_before
    remove_column :media, :has_poor_security
    remove_column :media, :whois_info_discrepency
    remove_column :media, :hosting_discrepency
    remove_column :media, :is_biased
    remove_column :media, :is_poorly_ranked
    remove_column :media, :is_not_liable
    remove_column :media, :lacks_flagging_means
    remove_column :media, :other_problems
    remove_column :media, :review_verdict
    remove_column :media, :review_description
    remove_column :media, :review_sharing_mode
    remove_column :media, :review_is_completed
  end
end

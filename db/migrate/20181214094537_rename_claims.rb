class RenameClaims < ActiveRecord::Migration[5.1]
  def change
    rename_column :claims, :claimid, :claim_id
    rename_column :claims, :claimtype, :claim_type
    rename_column :claims, :claimtitle, :claim_title
    rename_column :claims, :claimurl, :claim_url
    rename_column :claims, :claimsource, :claim_source
    rename_column :claims, :claimmedia, :claim_media    
  end
end

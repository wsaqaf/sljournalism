class RenameColumnsInClaims < ActiveRecord::Migration[5.1]
  def change
    rename_column :claims, :claim_title, :title
    rename_column :claims, :claim_type, :type
    rename_column :claims, :claim_url, :url
    rename_column :claims, :claim_source, :source
    rename_column :claims, :claim_media, :medium    
  end
end

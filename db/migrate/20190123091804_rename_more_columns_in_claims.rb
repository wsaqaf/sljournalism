class RenameMoreColumnsInClaims < ActiveRecord::Migration[5.1]
  def change
    remove_column :claims, :claim_source_name
    remove_column :claims, :claim_medium_name
    rename_column :claims, :medium, :medium_id
    rename_column :claims, :source, :source_id
  end
end

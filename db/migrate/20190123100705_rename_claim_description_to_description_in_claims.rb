class RenameClaimDescriptionToDescriptionInClaims < ActiveRecord::Migration[5.1]
  def change
    rename_column :claims, :claim_description, :description
  end
end

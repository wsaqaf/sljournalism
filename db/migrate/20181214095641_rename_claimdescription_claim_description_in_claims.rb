class RenameClaimdescriptionClaimDescriptionInClaims < ActiveRecord::Migration[5.1]
  def change
    rename_column :claims, :claimdescription, :claim_description    
  end
end

class AddClaimMediumNameToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :claim_medium_name, :string    
  end
end

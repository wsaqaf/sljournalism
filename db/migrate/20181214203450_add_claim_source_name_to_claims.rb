class AddClaimSourceNameToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :claim_source_name, :string
  end
end

class RemoveClaimIdFromClaims < ActiveRecord::Migration[5.1]
  def change
    remove_column :claims, :claim_id, :integer
  end
end

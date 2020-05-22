class RemovenoteClaimIdFromClaims < ActiveRecord::Migration[5.1]
  def change
    remove_column :claims, :note_claim_id
  end
end

class AddStatusOnBlockchainToClaims < ActiveRecord::Migration[5.2]
  def change
    add_column :claims, :status_on_blockchain, :string
  end
end

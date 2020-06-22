class AddBlockchainIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :blockchain_id, :string
    add_column :claims, :blockchain_id, :string
    add_column :claim_reviews, :blockchain_id, :string
  end
end

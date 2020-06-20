class AddAddToBlockchainToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :add_to_blockchain, :integer
    add_column :users, :time_added_to_blockchain, :datetime
    add_column :users, :blockchain_tx, :string
  end
end

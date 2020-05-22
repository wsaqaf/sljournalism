class AddBlockchainTxToClaimsAndClaimReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :claims, :time_added_to_blockchain, :datetime
    add_column :claims, :blockchain_tx, :string
    add_column :claim_reviews, :add_to_blockchain, :integer
    add_column :claim_reviews, :time_added_to_blockchain, :datetime
    add_column :claim_reviews, :blockchain_tx, :string
  end
end
